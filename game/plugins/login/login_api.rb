module AresMUSH
  class Character
    def is_guest?
      self.has_any_role?(Login.guest_role)
    end
    
    def last_on
      self.login_status ? self.login_status.last_on : nil
    end
  end
  
  module Login
    module Api
      def self.terms_of_service
        Login.terms_of_service
      end
            
      def self.change_password(char, password)
        char.change_password(password)
      end
      
      def self.is_site_match?(char, ip, hostname)
        Login.is_site_match?(char, ip, hostname)
      end
    end
  end
end
