require 'spec_helper'

describe Philotic::Routable do
  context "including the module on class" do
    let(:routable_event_class){
      Class.new do
        include Philotic::Routable
        attr_routable :routable_attr
        attr_payload :payload_attr
      end
    }
    subject { routable_event_class}

    %w{ attr_payload_reader attr_payload_readers 
        attr_payload_writer attr_payload_writers 
        attr_payload 
        
        attr_routable_reader attr_routable_readers 
        attr_routable_writers attr_routable_writer 
        attr_routable }.each do |method_name|
      specify { subject.methods.should include method_name.to_sym }
    end

    context " and then instantiating it" do
      let(:routable_event_instance){ routable_event_class.new }
      subject { routable_event_instance }

      it 'should have proper headers' do
        subject.headers.should == { routable_attr: nil }
      end

      it 'should have proper payload' do
        subject.payload.should == { payload_attr: nil }
      end

      it 'should have proper attributes' do
        subject.attributes.should == { routable_attr: nil,
                                       payload_attr: nil }
      end

      it 'should call Philotic::Publisher.publish with subject' do
        Philotic::Publisher.should_receive(:publish).with(subject)
        subject.publish
      end 

      it 'should have empty message_metadata' do
        subject.message_metadata.should == {}
      end

      context " overriding a value with message_metadata=" do
        before do
          routable_event_instance.message_metadata = { mandatory: false }
        end
        its(:message_metadata) { should eq( mandatory: false ) }
      end
    end
  end
end
