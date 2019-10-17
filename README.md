[![Build Status](https://travis-ci.org/DivanteLtd/anonymizer.svg?branch=master)](https://travis-ci.org/DivanteLtd/anonymizer) [![Test Coverage](https://api.codeclimate.com/v1/badges/e78aef36a350af5fd33c/test_coverage)](https://codeclimate.com/github/DivanteLtd/anonymizer/test_coverage)

# Anonymizer
Anonymizer is a universal tool to create anonymized DBs for projects.

Why is it so important to work with anonymized databases? In the development process, you should never use your production database - it is risky and against the law. Working with a production database in development is risky, because by some mistake, you can might make your clients data available to the whole world. In our world, general data is one of most valuable things and EU tries to protect citizens' general data via the General Data Protection Regulation (GDPR).

Some more quick wins for GDPR? Take a look at our [recent blog post](https://www.linkedin.com/pulse/gdpr-quick-wins-software-developers-teams-piotr-karwatka/?published=t).

## How does Anonymizer work?
Anonymizer replaces all data in your database by anonymized random data. The most important feature of Anonymizer is data formatting. All generated data is similar to the original data used by real users. The example below shows anonymized data in a Magento 1 sales_flat_quote_address table.

![Anonymized data example](https://user-images.githubusercontent.com/17312052/32728212-be7e07bc-c87f-11e7-9c83-5e6018819f50.png)

## Requirements

- ruby >= 2.2
- mysql >= 5.6

## Supported frameworks
- Magento 1.9.x / 2.x
- Pimcore 4 / 5
- Sylius 1.0.0-beta.2

Of course you can anonymize any other database - this is just an example.

## Getting started
Clone this repository and add a configuration file for your first project to the `config/project/` directory.

## Configuration file

### File name
The file name reflects the anonymized database's name. For example, if you need to anonymize a db dump named `example.sql.gz`, the configuration file should be named `example.json`.

### Basic configuration
#### Project type
Project configuration files always have an `extended` type. In the project configuration file, you have to set the `type` and `basic_type` which is connected with the supported framework. Only framework configuration files use the `basic`type.

#### Available basic types
* `custom`
* `magento_1_9`
* `magento_2_0`
* `pimcore_4`
* `pimcore_5`
* `sylius`

#### Change anonymized file's name
The anonymized dump is given the same name as the original database dump file. If you want to change this name, you can set the key `random_string` in configuration file - the value of this key will be added to end of the filename. In the example below, the output file will be named `example_ba74a64a152b84ec004d03caba15ba95.sql.gz`. 

#### Example

```
{
    "type": "extended",
    "basic_type": "magento_1_9",
    "random_string": "ba74a64a152b84ec004d03caba15ba95"

```


### Database dump location
Anonymizer can work with both locally and remotely stored database dumps. Database dumps from remote servers are downloaded by rsync.

#### Working with local database dump
In the example below, the database dump file is in the `/path/to/database/dump/` directory.

```
"dump_server": {
    "host": "",
    "port": "",
    "user": "",
    "path": "/path/to/database/dump/"
}
```

#### Working with remote database dump
In the example below, the database dump file is stored on a remote server with an IP address of `1.2.3.4` and ssh port of `5022`. The ssh user's name is `anonymizer`, the directory on remote host with the database dump is `/path/to/database/dump/`. In this case, let's assume that we need to add `--rsync-path=\"sudo rsync\"` option to our rsync dump download command.

```
"dump_server": {
    "host": "10.15.4.254",
    "user": "anonymizer",
    "port": "5022",
    "passphrase": "",
    "path": "/media/drbd0/backup/sqldump/sqldump",
    "rsync_options": "--rsync-path=\"sudo rsync\""
}
```

### Tables to anonymization

Anonymizer can replace the original data by anonymized entries or truncate the data in the destination table.

#### Available types of data

##### Simple types
- firstname
- lastname
- fullname
- ancestor
- login
- email
- telephone
- company
- street
- postcode
- city
- full_address
- vat_id
- ip
- quote
- website
- iban
- json

##### Special types
- uniq_email - unique email address, because of [bug in mysql](https://bugs.mysql.com/bug.php?id=89474), anonymizer can't generate uniq email address based on email and some unique value form UUID mysql methiod
- uniq_login - unique login
- regon - Polish REGON number with validation
- pesel - Polish PESEL number with validation

#### How to replace data in a table?
In the example below, data in the `user_address` table  will be replaced by new, anonymized data. The example database contains a `user_address` table with the following columns - `firstname`, `lastname`, `postcode`, `address`, `city`, `email`, `phone`,  `company`, `vat_id`. We will replace all columns' contents with some valid data, consistent with its previous type.A key must be specified if you want a better performance.To make Update faster you have to specify "Key":"1" to enable "SELECT FOR UPDATE" mode


```
"key":"1",  <===== This key must be added to make Multithreading Update Enable.
"tables": {
    "user_address": {
        "lastname": {
            "type": "lastname",
            "action": "update"
        },
        "postcode": {
            "type": "postcode",
            "action": "update"
        },
        "address": {
            "type": "street",
            "action": "update"
        },
        "city": {
            "type": "city",
            "action": "update"
        },
        "email": {
            "type": "email",
            "action": "update"
        },
        "phone": {
            "type": "telephone",
            "action": "update"
        },
        "company": {
            "type": "company",
            "action": "update"
        },
        "vat_id": {
            "type": "vat_id",
            "action": "update"
        },
        "firstname": {
            "type": "firstname",
            "action": "update",
            "key":"1"       <= The key column must be the LAST column after table declaration in json file.
        },
    }
}
```

#### How to truncate data in a table?
In the example below, the data in the `log_customer` table will be truncated.

```
"tables": {
    "log_customer": {
        "only_truncate": {
            "action": "truncate"
        }
    }
}
```

#### How to empty only selected columns in a table?
In the example below we will empty data in column with configuration values, keeping other columns intact.
```
"tables": {
    "some_configuration_table": {
        "config_value": {
            "action": "empty"
        }
    }
}
```

#### How to set static value to a column?
In below example value `PLN` will be assigned to column `base_currency` for all users.
```
"tables": {
    "users": {
        "base_currency": {
            "action": "set_static",
            "value": "PLN"
        }
    }
}
```

#### How to use Anonymizer with Magento EAV?
Anonymizer can also work with Magento's EAV model. In the example below, the customer attribute `about_me` in the  `customer_entity_text` table will be replaced with a random phrase.
```
"tables": {
    "customer_entity_text": {
        "value": {
            "action": "eav_update",
            "attributes": [
                {
                    "code": "about_me",
                    "type": "quote",
                    "entity_type": "customer"
                }
            ]
        }
    }
}
```

#### How to work with JSON data
Anonymizer can now update values of JSON encoded data. In below example we anonymize json stored in `additional_data` column.
You should familiarize with MySQL JSON path expressions.
```
{ "id": 123, "user": { "first_name": "John", "last_name": "Smith", "phone": "123-456-789" }, (...) }
```

```
"tables":{
    "subscriptions":{
        "additional_data":{
            "action":"json_update",
            "fields":[
                {
                    "path":"$.user.first_name",
                    "type":"firstname"
                },
                {
                    "path":"$.user.last_name",
                    "type":"lastname"
                },
                {
                    "path":"$.user.phone",
                    "type":"telephone"
                }
            ]
        }
    }
}
```

#### How to run custom queries

Anonymizer can run custom, row queries before and after anonymization process. In the example below, the anonymizer runs two queries before and one after.

```
"tables": {
},
"custom_queries": {
    "before": [
        "DELETE FROM some_column WHERE date > '2019-12-25'",
        "INSERT INTO some_column2 SET table = 'value'"
    ],
    "after": [
        "INSERT INTO some_column SET name = 'admin', pass = '1234567890'",
    ]
}
```

### Example configuration file
```
{
    "type": "extended",
    "basic_type": "magento_1_9",
    "random_string": "ba74a64a152b84ec004d03caba15ba95",
    "dump_server": {
        "host": "10.15.4.254",
        "user": "anonymizer",
        "port": "5022",
        "passphrase": "",
        "path": "/media/drbd0/backup/sqldump/sqldump",
        "rsync_options": "--rsync-path=\"sudo rsync\""
    }
    "tables": {
        "user_address": {
            "firstname": {
                "type": "firstname",
                "action": "update"
            },
            ...
        },
        "log_customer": {
            "only_truncate": {
                "action": "truncate"
            }
        },
        "customer_entity_text": {
            "value": {
                "action": "eav_update",
                "attributes": [
                    {
                        "code": "about_me",
                        "type": "quote",
                        "entity_type": "customer"
                    }
                ]
            }
        },
        "subscriptions":{
            "additional_data":{
                "action":"json_update",
                "fields":[
                    {
                        "path":"$.user.first_name",
                        "type":"firstname"
                    },
                    {
                        "path":"$.user.last_name",
                        "type":"lastname"
                    },
                    {
                        "path":"$.user.phone",
                        "type":"telephone"
                    }
                ]
            },
            "comment": {
                "type": "quote",
                "action": "update"
            }
        }
    }
```

### How to run the anonymization process

#### Configuration file for environment

Before you run anonymizer you should add configuration file. Copy sample config file from `config/env/sample.yml` to `config/env/<env_name>.yml`

```
RUBY_ENV=<env_name> bundle exec rake project:anonymize[example]
```

## Development

### Build environment

Run development docker environment using the command below:

```
docker-compose -f dev/docker/docker-compose.dev.yml up
```

### How to run the tests

On docker environment run the commands:

```
bundle install
bundle exec rspec spec/
```

## Contributing

If you'd like to contribute, please fork the repository and use a feature branch. Pull requests are warmly welcome.

## Licensing
The code featured in this project is licensed under MIT license.

## About Authors

![Divante-logo](http://divante.co/logo-HG.png "Divante")

We are a Software House from Europe, existing from 2008 and employing about 150 people. Our core competencies are built around Magento, Pimcore and bespoke software projects (we love Symfony3, Node.js, Angular, React, Vue.js). We specialize in sophisticated integration projects trying to connect hardcore IT with good product design and UX.

We work for Clients like INTERSPORT, ING, Odlo, Onderdelenwinkel or CDP, the company that produced The Witcher game. We develop two projects: [Open Loyalty](http://www.openloyalty.io/ "Open Loyalty") - loyalty program in open source and [Vue.js Storefront](https://github.com/DivanteLtd/vue-storefront "Vue.js Storefront").

We are part of the OEX Group which is listed on the Warsaw Stock Exchange. Our annual revenue has been growing at a minimum of about 30% year on year.

Visit our website [Divante.co](https://divante.co/ "Divante.co") for more information.
