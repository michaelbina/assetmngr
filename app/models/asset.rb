require 'aws/s3'

class Asset < ActiveRecord::Base
  acts_as_taggable
  
  def aws_connect
    AWS::S3::Base.establish_connection!(
      :access_key_id     => 'AKIAIFIQT4URJKGNI5KA',
      :secret_access_key => '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'
    )
  end
  
  def save_file(upload)
    return false if upload.blank?
    name =  self.id.to_s + "." + upload.original_filename

    self.aws_connect()
    AWS::S3::S3Object.store(name, upload, 'assetmngr', :access => :public_read)
    self.filename = name
    self.save
  end
end
