require 'system_spec_helper'

require 'net/scp'

RSpec.describe '#import database' do
  context 'copy dump' do
    before do
      @project_name = 'magento_1_9_sample'
      @anonymizer = Anonymizer.new @project_name
    end

    it 'should exists user private key' do
      expect(File.exist?(ENV['HOME'] + '/.ssh/id_rsa')).to be true
    end

    it 'should be loadded extension net/ssh and net/scp' do
      expect(Object.const_defined?('Net::SSH')).to be true
      expect(Object.const_defined?('Net::SCP')).to be true
    end

    it 'should has data necessary to connect to remote server' do
      expect(@anonymizer.config['dump_server']['host'].is_a?(String)).to be true
      expect(@anonymizer.config['dump_server']['user'].is_a?(String)).to be true
      expect(@anonymizer.config['dump_server']['port'].is_a?(String)).to be true
    end

    it 'should be possible connect to remote server' do
      expected = expect do
        Net::SSH.start(
          @anonymizer.config['dump_server']['host'],
          @anonymizer.config['dump_server']['user'],
          port: @anonymizer.config['dump_server']['port'],
          passphrase: @anonymizer.config['dump_server']['passphrase']
        )
      end

      expected.not_to raise_error
    end

    it 'should be possible copy project dump' do
      system(
        ShellHelper.download_dump(
          @project_name,
          {
            host: @anonymizer.config['dump_server']['host'],
            port: @anonymizer.config['dump_server']['port'],
            user: @anonymizer.config['dump_server']['user'],
            dump_dir: @anonymizer.config['dump_server']['path']
          },
          '/tmp',
          @anonymizer.config['dump_server']['rsync_options']
        )
      )

      expect(File.exist?("/tmp/#{@project_name}.sql.gz")).to be true
    end
  end
end
