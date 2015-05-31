require 'spec_helper'
require 'philotic/event'
# create 'deep' inheritance to test self.inherited
class TestEventParent < Philotic::Event
end
class TestEvent < TestEventParent
  attr_routable :routable_attr
  attr_payload :payload_attr
end

describe Philotic::Event do
  let(:event) { TestEvent.new }
  subject { event }

  %w[
      attr_routable_accessors
      attr_routable
      attr_payload_accessors
      attr_payload
  ].each do |method_name|
    specify { expect(subject.class.methods).to include method_name.to_sym }
  end

  it 'should have proper headers' do
    expect(subject.headers).to include({routable_attr: nil})
  end

  it 'should have proper payload' do
    expect(subject.payload).to eq({payload_attr: nil})
  end

  it 'should have proper attributes' do
    expect(subject.attributes).to include({routable_attr: nil, payload_attr: nil})
  end

  it 'should have empty metadata, other than timestamp' do
    expect(subject.metadata.keys).to eq([:timestamp])
  end

  context 'overriding a value with metadata=' do
    before do
      subject.metadata = {mandatory: false}
    end
    it 'should work' do
      expect(subject.metadata).to include({mandatory: false})
    end
  end

  Philotic::Event.methods.sort.each do |method_name|
    specify { expect(subject.class.methods).to include method_name.to_sym }
  end

  Philotic::MESSAGE_OPTIONS.each do |method_name|
    specify { expect(subject.methods).to include method_name.to_sym }
    specify { expect(subject.methods).to include "#{method_name}=".to_sym }
  end

  Philotic::PHILOTIC_HEADERS.each do |method_name|
    specify { expect(subject.methods).to include method_name.to_sym }
    specify { expect(subject.methods).to include "#{method_name}=".to_sym }
  end

  describe 'metadata' do
    it 'should have a timestamp' do
      Timecop.freeze
      expect(subject.metadata).to eq(timestamp: Time.now.to_i)
    end

    it 'should reflect changes in the event properties' do
      expect(subject.metadata[:app_id]).to eq nil
      subject.app_id = 'ANSIBLE'
      expect(subject.metadata[:app_id]).to eq 'ANSIBLE'
    end
  end
  describe 'headers' do
    it 'should include :philotic_product' do
      expect(subject.headers.keys).to include :philotic_product
    end
  end

  context 'generic event' do
    let(:headers) do
      {
        header1: 'h1',
        header2: 'h2',
        header3: 'h3',
      }
    end

    let(:payloads) do
      {
        payload1: 'h1',
        payload2: 'h2',
        payload3: 'h3',
      }
    end
    it 'builds an event with dynamic headers and payloads' do
      event = Philotic::Event.new(headers, payloads)

      expect(event.headers).to include(headers)
      expect(event.payload).to eq payloads

    end
  end

  describe '#publish' do
    subject { Philotic::Event.new }
    specify do
      expect(subject.connection).to receive(:publish).with(subject)

      subject.publish
    end

  end

  describe '.publish' do
    let (:connection) { double }
    let(:headers) do
      {
        header1: 'h1',
        header2: 'h2',
        header3: 'h3',
      }
    end

    let(:payloads) do
      {
        payload1: 'h1',
        payload2: 'h2',
        payload3: 'h3',
      }
    end
    subject { Philotic::Event }
    specify do
      expect_any_instance_of(Philotic::Event).to receive(:connection).and_return(connection)
      expect(connection).to receive(:publish) do |event|
        expect(event.headers).to include(headers)
        expect(event.payload).to eq payloads
      end

      subject.publish(headers, payloads)
    end

  end
end