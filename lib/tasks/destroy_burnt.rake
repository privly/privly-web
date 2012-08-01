namespace :db do
  desc "Destroy all posts which are past their burn dates"
  task :destroy_burnt_posts => :environment do
    puts "Destroying burnt posts"
    total_posts = Post.count
    Post.destroy_burnt_posts
    posts_remaining = Post.count
    puts "#{total_posts - posts_remaining} posts were destroyed"
    
    puts "Destroying burnt zero_bins"
    total_zero_bins = ZeroBin.count
    ZeroBin.destroy_burnt_zero_bins
    zero_bins_remaining = ZeroBin.count
    puts "#{total_zero_bins - zero_bins_remaining} zero_bins were destroyed"
  end
end
