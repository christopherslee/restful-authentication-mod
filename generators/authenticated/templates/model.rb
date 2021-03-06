require 'digest/sha1'

class <%= class_name %> < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
<% if options[:aasm] -%>
  include Authorization::AasmRoles
<% elsif options[:stateful] -%>
  include Authorization::StatefulRoles<% end %>
  validates_format_of       :first,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => false
  validates_length_of       :first,     :maximum => 40
  validates_format_of       :last,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => false
  validates_length_of       :last,     :maximum => 40

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  <% if options[:include_activation] && !options[:stateful] %>before_create :make_activation_code <% end %>

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :first, :last, :password, :password_confirmation

<% if options[:include_activation] && !options[:stateful] %>
  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end<% end %>

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = <% if    options[:stateful]           %>find_in_state :first, :active, :conditions => {:email => email.downcase}<%
           elsif options[:include_activation] %>find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]<%
           else %>find_by_email(email.downcase)<% end %> # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  protected
    
<% if options[:include_activation] -%>
    def make_activation_code
  <% if options[:stateful] -%>
      self.deleted_at = nil
  <% end -%>
      self.activation_code = self.class.make_token
    end
<% end %>

end
