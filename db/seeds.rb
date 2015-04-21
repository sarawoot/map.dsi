# User.create({
#   email: "admin@admin.com",
#   password: '12345678',
#   password_confirmation: '12345678',
#   admin: '1'
# })

atms  = AtmKtb.select("location, split_part(location, ' ', 1) lo1, split_part(location, ' ', 2) lo2, gid")
# binding.pry
atms.each{ |atm|
  if atm[:lo1].length <= 10
    atm[:short_name] = atm[:lo1] + " " + atm[:lo2]
  else
    atm[:short_name] = atm[:lo1]
  end
  atm.save
  puts "yes"
}