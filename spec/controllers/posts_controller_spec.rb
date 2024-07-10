require "rails_helper"

RSpec.describe PostsController do
  describe "#index" do
    context "jobseeker guides" do
      let(:subcategories) { %w[get-help-applying-for-your-teaching-role return-to-teaching-in-england] }

      it "finds the subcategories for jobseeker guides" do
        get :index, params: { section: "jobseeker-guides" }

        expect(assigns(:subcategories).sort).to eq(subcategories.sort)
      end
    end

    context "hiring staff guides" do
      let(:subcategories) { %w[how-to-create-job-listings-and-accept-applications how-to-setup-your-account] }

      it "finds the subcategories for jobseeker guides" do
        get :index, params: { section: "get-help-hiring" }

        expect(assigns(:subcategories)).to eq(subcategories)
      end
    end

    it "renders the index template" do
      get :index, params: { section: "jobseeker-guides" }

      expect(response).to render_template("index")
    end
  end

  describe "#subcategory" do
    context "jobseeker guides" do
      context "get-help-applying-for-your-teaching-role" do
        let(:post_names) do
          %w[
            prepare-for-a-teaching-job-interview-lesson
            3-quick-ways-to-find-the-right-teaching-job
            how-to-approach-a-teaching-job-interview
            write-a-great-teaching-job-application-in-five-steps
            how-to-write-teacher-personal-statement
            find-a-teaching-role-at-the-right-school
          ]
        end

        it "returns the correct guide posts" do
          get :subcategory, params: { section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role" }

          expect(assigns(:posts).map(&:post_name).sort).to eq(post_names.sort)
        end
      end

      context "return-to-teaching-in-england" do
        let(:post_names) do
          %w[
            return-to-teaching
            return-to-england-after-teaching-overseas
          ]
        end

        it "returns the correct guide posts" do
          get :subcategory, params: { section: "jobseeker-guides", subcategory: "return-to-teaching-in-england" }

          expect(assigns(:posts).map(&:post_name).sort).to eq(post_names.sort)
        end
      end
    end

    context "hiring staff guides" do
      context "how-to-create-job-listings-and-accept-applications" do
        let(:post_names) do
          %w[
            creating-the-perfect-teacher-job-advert
            accepting-job-applications-on-teaching-vacancies
            how-to-list-non-teaching-roles
          ]
        end

        it "returns the correct guide posts" do
          get :subcategory, params: { section: "get-help-hiring", subcategory: "how-to-create-job-listings-and-accept-applications" }

          expect(assigns(:posts).map(&:post_name).sort).to eq(post_names.sort)
        end
      end

      context "how-to-setup-your-account" do
        let(:post_names) do
          %w[
            how-to-request-organisation-access
            how-mats-can-use-teaching-vacancies
            how-to-approve-access-for-hiring-staff
          ]
        end

        it "returns the correct guide posts" do
          get :subcategory, params: { section: "get-help-hiring", subcategory: "how-to-setup-your-account" }

          expect(assigns(:posts).map(&:post_name).sort).to eq(post_names.sort)
        end
      end
    end

    it "renders the subcategory template" do
      get :subcategory, params: { section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role" }

      expect(response).to render_template("subcategory")
    end
  end

  describe "#show" do
    it "returns the correct post" do
      get :show, params: { section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role", post_name: "prepare-for-a-teaching-job-interview-lesson" }

      expect(assigns(:post).post_name).to eq("prepare-for-a-teaching-job-interview-lesson")
    end

    it "renders the show template" do
      get :show, params: { section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role", post_name: "prepare-for-a-teaching-job-interview-lesson" }

      expect(response).to render_template("show")
    end
  end
end
