namespace :forest do
  desc 'Generate the admin user and password.'
  task 'install:admin' => :environment do
    email = ENV['email']
    abort('[Forest] Error: Please specify an email environment variable for this admin user "rails forest:install:admin email=admin@example.com"') if email.blank?

    user = User.find_by_email(email)
    abort('[Forest] Error: An admin user for this email already exists') if user.present?

    password = SecureRandom.hex
    user = User.create(email: email, password: password)
    user_group = UserGroup.find_or_create_by(name: 'admin')
    user.user_groups << user_groups unless user.user_groups.include?(user_group)

    puts "[Forest] Admin user successfully created:"
    puts "[Forest] -- email: #{email}"
    puts "[Forest] -- password: #{password}"
  end
end
