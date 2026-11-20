# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication', type: :system do
  let!(:user) { create(:user, password: 'correct-password') }

  it 'signs in and signs out through Devise' do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'correct-password'
    click_on 'Log in'

    expect(page).to have_current_path(root_path)

    submit_sign_out_form
    visit new_user_session_path

    expect(page).to have_button('Log in')
  end

  private

  def submit_sign_out_form
    page.execute_script <<~JAVASCRIPT
      const form = document.createElement('form');
      form.method = 'post';
      form.action = '#{destroy_user_session_path}';

      const method = document.createElement('input');
      method.type = 'hidden';
      method.name = '_method';
      method.value = 'delete';
      form.appendChild(method);

      const token = document.createElement('input');
      token.type = 'hidden';
      token.name = 'authenticity_token';
      token.value = document.querySelector("meta[name='csrf-token']").content;
      form.appendChild(token);

      document.body.appendChild(form);
      form.submit();
    JAVASCRIPT

    expect(page).to have_current_path(root_path)
  end
end
