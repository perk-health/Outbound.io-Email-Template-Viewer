class LiquidFilesController < ApplicationController
  def viewer
    @file_name = params[:file_name]
    layout_file = File.read("../email-templates/template.liquid")
    @user_data = UserData.new(params[:first_name],
        params[:last_name], params[:openness],
        params[:conscientiousness], params[:extraversion], params[:agreeableness],
        params[:neuroticism], params[:last_behavior_created_at],
        params[:last_behavior_display_string]
      )
    if @file_name
      file = File.read("../email-templates/#{@file_name}.liquid")
      file = layout_file.gsub('{{ content }}', file)
      @file = convert_to_liquid(file)
      @template = Liquid::Template.parse(@file)
    else
      @template = nil
    end
  end

  private

  def convert_to_liquid(string)
    string = replace_attribues(string)
    string = replace_conditionals(string)
    string = replace_date_filter(string)
    string
  end

  ATTRIBUTE_MATCH = /({{ [a-zA-Z|'_ "]* }})/
  ATTRIBUTES = ['first_name', 'last_name', 'openness', 'conscientiousness', 'extraversion', 'agreeableness',
    'neuroticism', 'last_behavior_created_at', 'last_behavior_display_string' ]

  # string = "<p>{{ 'first_name' | UserAttribute }}, Congrats on your First Win!</p>"
  def replace_attribues(string)
    string.gsub!(ATTRIBUTE_MATCH) do |match|
      ATTRIBUTES.each do |attribute|
        next unless match.include?(attribute)
        match = "{{ #{attribute} }}"
      end
      match
    end
    string
  end

  CONDITIONAL_MATCH = /(({% if|{%if){1}[a-zA-Z0-9|'_ "><]{3,}%})/
  CONDITIONAL_OPERATORS = ['==', '!=', '>', '<', '>=', '<=']

  # string = "{% elif 'agreeableness' | UserAttribute < 0 %}"
  # string = "{%if 'neuroticism' | UserAttribute < 0 %}"
  def replace_conditionals(string)
    string.gsub!('elif', 'elsif')
    string.gsub!(CONDITIONAL_MATCH) do |match|
      tmp_attr = nil
      operator = nil
      ATTRIBUTES.each do |attribute|
        next unless match.include?(attribute)
        tmp_attr = attribute
      end
      CONDITIONAL_OPERATORS.each do |op|
        next unless match.include?(op)
        operator = op
      end
      if operator
        op_loc = match.index(operator)
        str_end = match.slice(op_loc..-1)
      else
        str_end = ' %}'
      end
      match = "{%if #{tmp_attr} #{str_end}"
      match
    end
    string
  end

  DATE_MATCH = /({{[a-zA-Z|'_ "]*(DateFormat)[a-zA-Z|'_ ,"%()]*}})/

  # string = "{{ 'last_behavior_created_at' | UserAttribute | DateFormat (', on %A, %b %d') , ''}}""
  def replace_date_filter(string)
    string.gsub!(DATE_MATCH) do |match|
      tmp_attr = nil
      ATTRIBUTES.each do |attribute|
        next unless match.include?(attribute)
        tmp_attr = attribute
      end
      index_start = match.index('(')
      index_end = match.index(')')

      date_string = match.slice(index_start + 1..index_end - 1)

      match = "{{ #{tmp_attr} | date: #{date_string} }}"
    end
    string
  end
end
