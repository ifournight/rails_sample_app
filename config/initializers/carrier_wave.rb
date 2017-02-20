if Rails.env.test? or Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
end

if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider:              'AWS',       
      aws_access_key_id:     'AKIAI22DA4WEUFJ6P6KA',
      aws_secret_access_key: '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'
    }
    config.fog_directory = 'railssampleappsh'
  end
end