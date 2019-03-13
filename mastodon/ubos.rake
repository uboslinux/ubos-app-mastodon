namespace :ubos do
  desc 'Provision admin user'
  task provision_admin: :environment do
    print 'Enter email: '
    email = STDIN.gets.chomp

    print 'Enter username: '
    username = STDIN.gets.chomp

    print 'Enter password: '
    password = STDIN.gets.chomp

    user = User.new(email: email, password: password, account_attributes: { username: username }, admin: true, confirmed_at: Time.now.utc, agreement: true )
    if user.save
      puts 'User created.'
    else
      puts 'Errors occured while creating new user:'
      user.errors.each do |key, val|
        puts "#{key}: #{val}"
      end
      exit 1
    end
  end
end
