require 'colored'
require 'fileutils'
require_relative '../mgc/yp_makegarbagecode'
require_relative '../log/yp_log'

class YPUpdate
  def self.update
      yp_log_doing '准备更新...'
        
      system("gem install colored")
      system("gem install bundler")
      system("gem install rake")
      system("gem install yptools")

      yp_log_success "更新YPTools完成"
      
  end

end
