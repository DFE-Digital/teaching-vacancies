RSpec.shared_examples Counter do
  describe '#track' do
    let(:redis_counter) { spy(increment: true) }
    before do
      allow(model).to receive(described_class.redis_counter_name) { redis_counter }
    end

    it 'increments the click counter' do
      counter.track

      expect(redis_counter).to have_received(:increment)
    end
  end

  describe '#persist!' do
    let(:redis_counter) { spy(to_i: 30) }
    let(:clicks) { 2 }

    before do
      model.send("#{described_class.persisted_column}=", clicks)
      model.save
      allow(model).to receive(described_class.redis_counter_name) { redis_counter }
    end

    it 'adds to and updates the total clicks' do
      counter.persist!

      expect(model.send(described_class.persisted_column)).to eq(32)
    end

    it 'saves the time the total clicks were updated' do
      freeze_time do
        counter.persist!

        expect(model.send("#{described_class.persisted_column}_updated_at")).to eq(Time.zone.now)
      end
    end

    context 'the existing clicks are nil' do
      let(:clicks) { nil }

      it 'updates the total clicks' do
        counter.persist!

        expect(model.send(described_class.persisted_column)).to eq(30)
      end
    end

    context 'the clicks are persisted' do
      before do
        allow(model).to receive(:save).and_return(true)
      end

      it 'resets the click counter' do
        counter.persist!

        expect(redis_counter).to have_received(:reset)
      end
    end

    context 'the clicks are not persisted' do
      before do
        allow(model).to receive(:save).and_return(false)
      end

      it 'does not reset the click counter' do
        counter.persist!

        expect(redis_counter).not_to have_received(:reset)
      end
    end

    context 'when the click counter is 0' do
      let(:redis_counter) { spy(to_i: 0) }

      it 'does not save the vacancy' do
        expect(model).to_not receive(:save)

        counter.persist!
      end
    end
  end
end
