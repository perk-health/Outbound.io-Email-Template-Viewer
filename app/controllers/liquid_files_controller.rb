class LiquidFilesController < ApplicationController
  FILES = [
    ['Non Coaching',[
      ['Comment Notification', 'non-coaching/comment_notification'],
      ['Friend Request Notification', 'non-coaching/friend_request_notification'],
      ['Kudos Notification', 'non-coaching/kudos_notification'],
      ['Post Notification', 'non-coaching/post_notification'],
    ]], ['Coaching', [
      ['Accepted Invitation', 'coaching/accept_invitation'],
      ['1st Monday', 'coaching/1st_monday'],
      ['5th Win', 'coaching/5th_win'],
      ['15th Win', 'coaching/15th_win'],
      ['25th Win', 'coaching/25th_win'],
      ['50th Win', 'coaching/50th_win'],
      ['70th Win', 'coaching/70th_win'],
      ['100th Win', 'coaching/100th_win']
    ]], ['Old Habit Course', [
      ['Habit Course Intro', 'habit-course/intro'],
      ['Habit Course Lesson 1', 'habit-course/Lesson-1'],
      ['Habit Course Lesson 2', 'habit-course/Lesson-2'],
      ['Habit Course Lesson 3', 'habit-course/Lesson-3'],
      ['Habit Course Lesson 4', 'habit-course/Lesson-4'],
      ['Habit Course Lesson 5', 'habit-course/Lesson-5'],
      ['Habit Course Lesson 6', 'habit-course/Lesson-6']
    ]], ['Archived', [
      ['First Win', 'archive/first_win_email'],
      ['No Win', 'archive/no_win'],
      ['Welcome Message', 'archive/welcome_email'],
      ['Long Reminder Email', 'archive/long_reminder_email'],
      ['Quick Reminder Email', 'archive/quick_reminder'],
      ['Personality Report', 'archive/personality_report'],
      ['Reminder Email (3 Days)', 'archive/reminder_email_3d'],
      [' Reminder Email (7 Days)', 'archive/reminder_email_7d'],
      [' Reminder Email (7 Days - Infinite)', 'archive/reminder_email_7d'],
      [' Reminder Email (14 Days)', 'archive/reminder_email_14d'],
      [' Reminder Email (30 Days)', 'archive/reminder_email_30d'],
      [' Reminder Email (60 Days)', 'archive/reminder_email_60d'],
      [' Reminder Email (90 Days)', 'archive/reminder_email_90d']
    ]]
  ]
  def viewer
    @file_name = params[:file_name]
    @files = FILES
    Liquid::Template.error_mode = :strict
    layout_file = File.read("../email-templates/template.liquid")
    @user_data = build_user_data(params)

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

  def build_user_data(params)
    user_data = UserData.new
    ATTRIBUTES.each do |attribute|
      val = params[attribute.to_sym]
      next unless val
      user_data.send("#{attribute}=", val)
    end
    user_data
  end

  def convert_to_liquid(string)
    string = replace_attribues(string)
    string = replace_conditionals(string)
    string = replace_date_filter(string)
    string
  end

  ATTRIBUTE_MATCH = /({{ [a-zA-Z|'_ "]* }})/
  ATTRIBUTES = UserData.attributes

  # string = "<p>{{ 'first_name' | UserAttribute }}, Congrats on your First Win!</p>"
  def replace_attribues(string)
    string.gsub!(ATTRIBUTE_MATCH) do |match|
      ATTRIBUTES.each do |attribute|
        next unless match.include?("'#{attribute}'")
        match = "{{ #{attribute} }}"
      end
      match
    end
    string
  end

  CONDITIONAL_MATCH = /(({% if|{%if|{% elsif|{%elsif){1}[a-zA-Z0-9\-|'_ "><]{3,}%})/
  CONDITIONAL_OPERATORS = ['==', '!=', '>', '<', '>=', '<=']

  # string = "{% elif 'agreeableness' | UserAttribute < 0 %}"
  # string = "{%if 'neuroticism' | UserAttribute < 0 %}"
  def replace_conditionals(string)
    string.gsub!('elif', 'elsif')
    string.gsub!(CONDITIONAL_MATCH) do |match|
      is_elsif = !match.index('elsif').nil?
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
      if is_elsif
        match = "{%elsif #{tmp_attr} #{str_end}"
      else
        match = "{%if #{tmp_attr} #{str_end}"
      end
      match
    end
    string
  end

  DATE_MATCH = /({{[a-zA-Z|'_ "]*(DateFormat)[a-zA-Z|'_ ,"%()]*}})/
  COMMA_IN_DATE_FORMAT_MATCH = /(' , ''\)|', ''\)|',''\))/
  # string = "{{ 'last_behavior_created_at' | UserAttribute | DateFormat (', on %A, %b %d' , '')}}"
  def replace_date_filter(string)
    string.gsub!(DATE_MATCH) do |match|
      tmp_attr = nil
      ATTRIBUTES.each do |attribute|
        next unless match.include?(attribute)
        tmp_attr = attribute
      end
      index_start = match.index('(')
      index_end = match.index(COMMA_IN_DATE_FORMAT_MATCH)

      date_string = match.slice(index_start + 1..index_end)

      match = "{{ #{tmp_attr} | date: #{date_string} }}"
    end
    string
  end
end
