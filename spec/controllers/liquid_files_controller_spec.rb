require 'rails_helper'

RSpec.describe LiquidFilesController, type: :controller do
  let(:attr_string) { "<p>{{ 'first_name' | UserAttribute }}, Congrats on your First Win!</p>" }
  let(:attr_result) { "<p>{{ first_name }}, Congrats on your First Win!</p>"}

  let(:elif_string) { "<p>{% elif 'agreeableness' | UserAttribute < 0 %}, Congrats on your First Win!" }
  let(:elif_result) { "<p>{%elsif agreeableness < 0 %}, Congrats on your First Win!" }

  let(:if_string) { "<p>{%if 'neuroticism' | UserAttribute < 0 %}, Congrats on your First Win!" }
  let(:if_result) { "<p>{%if neuroticism < 0 %}, Congrats on your First Win!" }

  let(:if_string2) { "<p>{%if 'openness' | UserAttribute < -1 %}, Congrats on your First Win!" }
  let(:if_result2) { "<p>{%if openness < -1 %}, Congrats on your First Win!" }

  let(:blank_if_string) { "<p>{%if 'neuroticism' | UserAttribute %}, Congrats on your First Win!" }
  let(:blank_if_result) { "<p>{%if neuroticism  %}, Congrats on your First Win!" }

  let(:date_format_string) { "<p>{{ 'last_behavior_created_at' | UserAttribute | DateFormat (', on %A, %b %d' , '')}}, Congrats on your First Win!" }
  let(:date_format_result) { "<p>{{ last_behavior_created_at | date: ', on %A, %b %d' }}, Congrats on your First Win!" }

  describe 'replace_attribues' do
    it { expect(subject.send(:replace_attribues, attr_string)).to eq attr_result }

    it { expect(subject.send(:replace_attribues, elif_string)).to eq elif_string }
    it { expect(subject.send(:replace_attribues, if_string)).to eq if_string }
    it { expect(subject.send(:replace_attribues, blank_if_string)).to eq blank_if_string }
    it { expect(subject.send(:replace_attribues, date_format_string)).to eq date_format_string }
  end

  describe 'replace_conditionals' do
    it { expect(subject.send(:replace_conditionals, elif_string)).to eq elif_result }
    it { expect(subject.send(:replace_conditionals, if_string)).to eq if_result }
    it { expect(subject.send(:replace_conditionals, if_string2)).to eq if_result2 }
    it { expect(subject.send(:replace_conditionals, blank_if_string)).to eq blank_if_result }

    it { expect(subject.send(:replace_conditionals, attr_string)).to eq attr_string }
    it { expect(subject.send(:replace_conditionals, date_format_string)).to eq date_format_string }
  end

  describe 'replace_date_filter' do
    it { expect(subject.send(:replace_date_filter, date_format_string)).to eq date_format_result }

    it { expect(subject.send(:replace_date_filter, elif_string)).to eq elif_string }
    it { expect(subject.send(:replace_date_filter, if_string)).to eq if_string }
    it { expect(subject.send(:replace_date_filter, attr_string)).to eq attr_string }
    it { expect(subject.send(:replace_date_filter, blank_if_string)).to eq blank_if_string }
  end
end
