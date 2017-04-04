class SharedFileUploader < CarrierWave::Uploader::Base

 if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    if model.name.present?
      "#{model.name.strip.gsub(' ', '_').gsub(/[^\w-]/, '')}.#{model.file.file.extension}"
    elsif original_filename.present?
      original_filename
    end
  end
end
