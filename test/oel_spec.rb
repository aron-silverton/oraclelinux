require_relative 'spec_helper'

describe 'box' do
  it 'should have a root user' do
    expect(user 'root').to exist
  end

  it 'should disable SELinux' do
    expect(selinux).to be_disabled
  end

  vbox_string = command("dmesg | grep VirtualBox").stdout
  has_vbox = vbox_string.include? 'VirtualBox'
  it 'should have single-request-reopen on virtualbox', :if => has_vbox do
    if file('/redhat/release').content.scan(/(release 5) | (release 6)/)
      if ! file('/etc/gdm/custom.conf').file? 
        expect(file('/etc/resolv.conf').content).to match /single-request-reopen/
      end
    end
  end

  # https://www.chef.io/blog/2015/02/26/bento-box-update-for-centos-and-fedora/
  describe 'test-cacert' do
    it 'uses the vendor-supplied openssl certificates' do
      expect(command('openssl s_client -CAfile /etc/pki/tls/certs/ca-bundle.crt -connect packagecloud-repositories.s3.amazonaws.com:443 </dev/null 2>&1 | grep -i "verify return code"').stdout).to match /\s+Verify return code: 0 \(ok\)/
    end
  end

  has_docker = command('command -v docker').exit_status == 0
  it 'should make vagrant a member of the docker group', :if => has_docker do
    expect(user 'vagrant').to belong_to_group 'docker'
  end
end
