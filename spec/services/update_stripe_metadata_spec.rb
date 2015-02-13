require "spec_helper"

describe UpdateStripeMetadata do
  describe "#run" do
    context "updates successfully" do
      it "updates stripe metadata with repo id" do
        user = create(:user, stripe_customer_id: stripe_customer_id)
        repo = create(:repo, private: true)
        subscription = create(
          :subscription,
          stripe_subscription_id: stripe_subscription_id,
          user: user,
          repo: repo
        )
        stub_customer_find_request
        stub_subscription_find_request(subscription)
        stripe_update_request = stub_subscription_meta_data_update_request(
          repo.id
        )

        UpdateStripeMetadata.run

        expect(stripe_update_request).to have_been_requested
      end
    end

    context "does not update" do
      it "will not update if repo does not have subscription" do
        create(:repo)
        stripe_customer_find_request = stub_customer_find_request

        UpdateStripeMetadata.run

        expect(stripe_customer_find_request).not_to have_been_requested
      end

      it "will not update stripe when stripe_customer_id is missing" do
        user = create(:user, stripe_customer_id: nil)
        repo = create(:repo, private: true)
        create(
          :subscription,
          user: user,
          repo: repo
        )

        UpdateStripeMetadata.run

        stripe_customer_find_request = stub_customer_find_request

        expect(stripe_customer_find_request).not_to have_been_requested
      end
    end
  end
end
