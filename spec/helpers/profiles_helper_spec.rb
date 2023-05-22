require "rails_helper"

RSpec.describe ProfilesHelper do
  describe "#jobseeker_status" do
    let(:profile) { instance_double("profile") }
    let(:personal_details) { instance_double("personal_details", right_to_work_in_uk: right_to_work_in_uk) }

    before do
      allow(profile).to receive(:personal_details).and_return(personal_details)
    end

    context "when profile right_to_work_in_uk == true" do
      let(:right_to_work_in_uk) { true }

      context "when qualified teacher status is `yes`" do
        before do
          allow(profile).to receive(:qualified_teacher_status_year).and_return("2020")
          allow(profile).to receive(:qualified_teacher_status).and_return("yes")
        end

        it "returns correct string" do
          expect(helper.jobseeker_status(profile)).to eq "QTS awarded in 2020. Has the right to work in the UK."
        end
      end

      context "when qualified teacher status is `no`" do
        before do
          allow(profile).to receive(:qualified_teacher_status).and_return("no")
        end

        it "returns correct string" do
          expect(helper.jobseeker_status(profile)).to eq "Does not have QTS. Has the right to work in the UK."
        end
      end

      context "when qualified teacher status is `on_track`" do
        before do
          allow(profile).to receive(:qualified_teacher_status).and_return("on_track")
        end

        it "returns correct string" do
          expect(helper.jobseeker_status(profile)).to eq "On track to receive QTS. Has the right to work in the UK."
        end
      end
    end

    context "when profile right_to_work_in_uk == true" do
      let(:right_to_work_in_uk) { false }

      context "when qualified teacher status is `yes`" do
        before do
          allow(profile).to receive(:qualified_teacher_status_year).and_return("2020")
          allow(profile).to receive(:qualified_teacher_status).and_return("yes")
        end

        it "returns correct string" do
          expect(helper.jobseeker_status(profile)).to eq "QTS awarded in 2020. Does not have the right to work in the UK."
        end
      end

      context "when qualified teacher status is `no`" do
        before do
          allow(profile).to receive(:qualified_teacher_status).and_return("no")
        end

        it "returns correct string" do
          expect(helper.jobseeker_status(profile)).to eq "Does not have QTS. Does not have the right to work in the UK."
        end
      end

      context "when qualified teacher status is `on_track`" do
        before do
          allow(profile).to receive(:qualified_teacher_status).and_return("on_track")
        end

        it "returns correct string" do
          expect(helper.jobseeker_status(profile)).to eq "On track to receive QTS. Does not have the right to work in the UK."
        end
      end
    end

    context "when profile right_to_work_in_uk == true" do
      let(:right_to_work_in_uk) { nil }

      context "when qualified teacher status is `yes`" do
        before do
          allow(profile).to receive(:qualified_teacher_status_year).and_return("2020")
          allow(profile).to receive(:qualified_teacher_status).and_return("yes")
        end

        it "returns correct string" do
          expect(helper.jobseeker_status(profile)).to eq "QTS awarded in 2020."
        end
      end

      context "when qualified teacher status is `no`" do
        before do
          allow(profile).to receive(:qualified_teacher_status).and_return("no")
        end

        it "returns correct string" do
          expect(helper.jobseeker_status(profile)).to eq "Does not have QTS."
        end
      end

      context "when qualified teacher status is `on_track`" do
        before do
          allow(profile).to receive(:qualified_teacher_status).and_return("on_track")
        end

        it "returns correct string" do
          expect(helper.jobseeker_status(profile)).to eq "On track to receive QTS."
        end
      end
    end
  end
end
