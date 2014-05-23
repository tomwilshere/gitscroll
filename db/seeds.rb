# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Metric.create([{name: 'wilt', extension_list: ''}, {name: 'num_lines', extension_list: ''}, { name: 'flog', extension_list: 'rb'}, {name: 'rubocop', extension_list: 'rb'}])