class AwsJob

  def perform(data)
    puts "Working"
    puts data.inspect

    job = ConfigJob.first :token => data[:token]

    AWS.config access_key_id: job.aws_account.access_key, secret_access_key: job.aws_account.secret_key, region: job.aws_account.region
    ec2 = AWS.ec2

    ssh_config = "###############################################
## AWS Account: #{job.aws_account.name}"
    progress = 0
    i = 0
    
    total_instances = ec2.instances.count

    ec2.instances.each do |instance|
      if(instance.status == :running && instance.tags['Name'])
        instance_name = instance.tags['Name'].gsub /[^a-zA-Z0-9\-_\.]/, '-'
        instance_user = instance.tags['User'] || 'ubuntu'
        puts "#{instance.id}: #{instance_name} #{instance.ip_address} (#{instance_user})"
        ssh_config << "Host #{instance_name}\n"
        ssh_config << "  HostName #{instance.ip_address}\n"
        ssh_config << "  User #{instance_user}\n"
        ssh_config << "  IdentityFile ~/.ssh/#{job.aws_account.name}.aws.pem\n"
        ssh_config << "\n"
      end

      update = ConfigJob.first :token => data[:token]
      update.config = ssh_config
      update.status = ((i * 100) / total_instances).to_i
      update.save

      i += 1
    end

    update = ConfigJob.first :token => data[:token]
    update.status = 'complete'
    update.save

    puts "Done"
    puts "..."
  end
end