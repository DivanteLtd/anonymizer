[![Build Status](https://travis-ci.org/DivanteLtd/anonymizer.svg?branch=master)](https://travis-ci.org/DivanteLtd/anonymizer)

# Anonymizer
Anonymizer is universal tool to create anonymized DB for projects.

## Requritsments

- ruby >= 2.1
- mysql >= 5.6

## Supported framework
- Magento 1.9.x / 2.x
- Pimcore 4 / 5
- Sylius  1.0.0-beta.2

Of course you can anonymize any other database.

## Getting started
Clone this repository and to direcry `config/project/` add configuration file for your first project.

## Configuration file

### File name
File name is anonymized data base name. For example, if you need anonymize db dump damed `example.sql.gz` configuration file should have name example.json.

### Basic configuration
#### Project type
Project configuration files always has type `extended`. In project configuration file you have to set type and basic_type whith is connected with supported framowork. Only configuration files for framowork has type `basic`.

#### Available basic types
* `custom`
* `magento_1_9`
* `magento_2_0`
* `pimcore_4`
* `pimcore_5`
* `sylius`

#### Change anonymized file name
Anonymized dump has name the same as original database dump file. If you want change this name you can set key `random_string` in configuration file, value of this key will be added to end of name of file. In example below output file has name `example_ba74a64a152b84ec004d03caba15ba95.sql.gz`.

#### Example

```
{
    "type": "extended",
    "basic_type": "magento_1_9",
    "random_string": "ba74a64a152b84ec004d03caba15ba95",

```


### Database dump location
Anonymizer can work with both localy and remotly stored database dupms. Database dump from remote server is downloaded by rsync.

#### Working with local database dupm
In example below database dump file is in directory `/path/to/databse/dump/`

```
"dump_server": {
    "host": "",
    "port": "",
    "user": "",
    "path": "/path/to/databse/dump/"
}
```

#### Working with local database dupm
In example below database dump file is stored on remote server with IP address `1.2.3.4` and ssh port `5022`, user to ssh connection has name `anonymizer`, directory on remote host with database dump is `/path/to/databse/dump/` and we need to add option to rsync command `--rsync-path=\"sudo rsync\"`

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

### Tables to anonimization

Anonymizer can replace original data by anonymized data or truncate data in table.

#### How to replace data in table?
In example below data in table user_address will be replaced with new anonymized data. In that example id databse we have table `user_address` with columns `firstname`, `lastname`, `postcode`, `address`, `city`, `email`, `phone`,  `company`, `vat_id` and to all columns we need set some valid data consistent with type.

```
"tables": {
    "user_address": {
        "firstname": {
            "type": "firstname",
            "action": "update"
        },
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
        }
    }
}
```

#### How to truncate data in table?
In example below data in table log_customer will be truncated

```
"tables": {
    "log_customer": {
        "only_truncate": {
            "action": "truncate"
        }
    }
}
```

#### How to work with Magento EAV?
Anonymizer can work with Magento EAV model. In example below customer attribute `about_me` in table customer_entity_text will be replaced with some random phrase.
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

### Configuration file example
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
        }
    }
```

### How to run anonymization
```
RUBY_ENV=production bundle exec rake project:anonymize[example]
```

## Developing

## Contributing

If you'd like to contribute, please fork the repository and use a feature branch. Pull requests are warmly welcome.

## Licensing
The code in this project is licensed under MIT license.

## About Authors

![Divante-logo](http://divante.co///logo_1.png "Divante")

We are a Software House from Europe, headquartered in Poland and employing about 150 people. Our core competencies are built around Magento, Pimcore and bespoke software projects (we love Symfony3, Node.js, Angular, React, Vue.js). We specialize in sophisticated integration projects trying to connect hardcore IT with good product design and UX.

Visit our website [Divante.co](https://divante.co/ "Divante.co") for more information.