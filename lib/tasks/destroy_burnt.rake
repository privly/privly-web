namespace :db do
  desc "Destroy all posts which are past their burn dates"
  task :destroy_burnt_posts => :environment do
    puts "Destroying burnt posts"
    total_posts = Post.count
    Post.destroy_burnt_posts
    posts_remaining = Post.count
    puts "#{total_posts - posts_remaining} posts were destroyed"
  end
end
