require "digest/md5"

class Message < Sequel::Model

  plugin :timestamps

  def before_create
    generate_hash_id
    super
  end

  def ndc_errors=(errors)
    self[:ndc_errors] = errors.map{|err| "#{err.class}||#{err}"}.join('\n')
  end

  def ndc_errors
    self[:ndc_errors].split('\n').map{|err| [err.slice(/^(\S+)\|\|/, 1), err.slice(/^\S+\|\|(.+)/, 1)]}
  end

  def generate_hash_id
    self.hash_id = Digest::MD5.hexdigest(Time.now.to_s)
  end

  def has_errors?
    self.ndc_errors.present?
  end

end
