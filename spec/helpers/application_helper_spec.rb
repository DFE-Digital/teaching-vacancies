require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#sanitize" do
    it "it sanitises the text" do
      html = "<p> a paragraph <a href='link'>with a link</a></p><br>"
      sanitized_html = "<p> a paragraph with a link</p><br>"

      expect(helper.sanitize(html)).to eq(sanitized_html)
    end
  end

  describe "#body_class" do
    before do
      expect(controller).to receive(:controller_path) { "foo/baz" }
      expect(controller).to receive(:action_name) { "bar" }
      allow(controller).to receive(:publisher_signed_in?) { false }
    end

    it "returns the controller and action name" do
      expect(helper.body_class).to match(/foo_baz_bar/)
    end

    it "does not return the authenticated class" do
      expect(helper.body_class).to_not match(/publisher/)
    end

    context "when logged in" do
      before do
        expect(controller).to receive(:publisher_signed_in?) { true }
      end

      it "returns the authenticated class" do
        expect(helper.body_class).to match(/publisher/)
      end
    end
  end

  describe "#can_send_message?" do
    let(:job_application) { create(:job_application, status: "submitted") }

    context "when user is a jobseeker" do
      let(:jobseeker) { create(:jobseeker) }

      context "when no conversations exist" do
        it "calls can_jobseeker_initiate_message?" do
          expect(job_application).to receive(:can_jobseeker_initiate_message?).and_return(true)
          expect(helper.can_send_message?(job_application, jobseeker)).to be true
        end
      end

      context "when conversations exist" do
        before do
          create(:conversation, job_application: job_application)
        end

        it "calls can_jobseeker_reply_to_message?" do
          expect(job_application).to receive(:can_jobseeker_reply_to_message?).and_return(true)
          expect(helper.can_send_message?(job_application, jobseeker)).to be true
        end
      end
    end

    context "when user is a publisher" do
      let(:publisher) { create(:publisher) }

      it "calls can_publisher_send_message?" do
        expect(job_application).to receive(:can_publisher_send_message?).and_return(true)
        expect(helper.can_send_message?(job_application, publisher)).to be true
      end

      it "returns false when can_publisher_send_message? returns false" do
        expect(job_application).to receive(:can_publisher_send_message?).and_return(false)
        expect(helper.can_send_message?(job_application, publisher)).to be false
      end
    end

    context "when user is neither jobseeker nor publisher" do
      let(:other_user) { double("OtherUser") } # rubocop:disable RSpec/VerifiedDoubles

      it "returns false" do
        expect(helper.can_send_message?(job_application, other_user)).to be false
      end
    end

    context "when user is nil" do
      it "returns false" do
        expect(helper.can_send_message?(job_application, nil)).to be false
      end
    end
  end
end
