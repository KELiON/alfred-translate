# encoding: UTF-8

require 'open-uri'
require 'json'
require 'builder'

def translate phrase
  source = 'ru'
  target = 'en'

  # auto detect languge
  if phrase.match(/[a-zA-Z]+/)
    source = 'en'
    target = 'ru'
  end

  json = open('http://translate.google.com/translate_a/t?client=p&text='+URI::encode(phrase)+'&hl=en-EN&sl='+source+'&tl='+target+'&multires=1&ssel=0&tsel=0&sc=1&ie=UTF-8&oe=UTF-8').read
  json = JSON::parse(json)

  xml = Builder::XmlMarkup.new(indent: 2)
  xml.instruct! :xml, encoding: "utf-8"
  xml.items do |items|
    if json['dict']
      json['dict'][0]['entry'].each do |r|
        items.item(uid: 'mtranslate', arg: r['word']) do |item|
          item.title r['word']
          item.subtitle r['reverse_translation'].join(',')
          item.icon "Icons/#{target}.png"
        end
      end
    elsif json['sentences']
      json['sentences'].each do |s|
        items.item(uid: 'mtranslate', arg: s['trans']) do |item|
          item.title s['trans']
          item.subtitle s['orig']
          item.icon "Icons/#{target}.png"
        end
      end
    else
      items.item(uid: 'mtranslate') do |item|
        item.title "No result found"
      end
    end
  end
  puts xml.to_s
end