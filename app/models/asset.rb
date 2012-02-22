require 'aws/s3'

class Asset < ActiveRecord::Base
  acts_as_taggable
  
  
  # connect to Amazon S3
  # TODO: run this only once
  def aws_connect
    AWS::S3::Base.establish_connection!(
      :access_key_id     => 'AKIAIFIQT4URJKGNI5KA',
      :secret_access_key => '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'
    )
  end
  
  # save a file to Amazon S3 and store the filename for retrieval
  def save_file(upload)
    return false if upload.blank?
    name =  self.id.to_s + "." + upload.original_filename

    self.aws_connect()
    
    # store the file to Amazon S3
    AWS::S3::S3Object.store(name, upload, 'assetmngr', :access => :public_read)
    self.filename = name
    self.save
  end
end
