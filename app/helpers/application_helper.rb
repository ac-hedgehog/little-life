module ApplicationHelper
  def init_action_js(*args)
    javascript_tag <<-JAVASCRIPT
        $(document).ready(function(){
            $.app.#{params[:controller]}.setup_#{params[:action]}(
                #{args.map{|arg|"JSON.parse('#{arg.to_json}')"}.join(',')}
            );
        });
    JAVASCRIPT
  end
end
