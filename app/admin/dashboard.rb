ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    # Here is an example of a simple dashboard with columns and panels.
    #
    # total users
    # 10 most recent user accounts created
    # 10 most recent users to have created content
    # most requested user content, fails and successes
    # 
    columns do
      column do
        panel "Recently Added Users" do
          ul do
            User.where(:can_post => true).order("id DESC").first(10).map do |user|
              li link_to(user.email, admin_user_path(user)) + " Post Count: #{user.posts.count}"
            end
          end
        end
      end

      column do
        panel "Recently Loged In Users" do
          ul do
            User.order("current_sign_in_at DESC").first(10).each do |user|
              li link_to(user.email, admin_user_path(user)) + " Last: #{user.current_sign_in_at}"
            end
          end
        end
      end
    end
    columns do
      column do
        panel "Top Users By Successfull Requests" do
          ul do
            User.order("permissioned_requests_served DESC").first(10).map do |user|
              li link_to(user.email, admin_user_path(user)) + " Permissioned Requests Served: #{user.permissioned_requests_served}"
            end
          end
        end
      end
      column do
        panel "Top Users By Unsuccessfull Requests" do
          ul do
            User.order("nonpermissioned_requests_served DESC").first(10).map do |user|
              li link_to(user.email, admin_user_path(user)) + " Non-Permissioned Requests Served: #{user.nonpermissioned_requests_served}"
            end
          end
        end
      end
    end
  end # content
end
