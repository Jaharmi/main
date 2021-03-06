require File.dirname(__FILE__) + '/../../spec_helper'

not_supported_on :ironruby do
require File.dirname(__FILE__) + '/shared/resume'

ruby_version_is "1.9" do
  describe "Fiber#transfer" do
    
    require 'fiber'

    it_behaves_like(:resume, :transfer)

    it "transfers control from one Fiber to another when called from a Fiber" do
      fiber1 = Fiber.new { :fiber1 }
      fiber2 = Fiber.new { fiber1.transfer; :fiber2 }
      fiber2.resume.should == :fiber1
    end

    it "can be invoked from the same Fiber it transfers control to" do
      states = []
      fiber = Fiber.new { states << :start; fiber.transfer; states << :end } 
      fiber.transfer
      states.should == [:start, :end]

      states = []
      fiber = Fiber.new { states << :start; fiber.transfer; states << :end } 
      fiber.resume
      states.should == [:start, :end]
    end    

    it "can transfer control to a Fiber that has transfered to another Fiber" do
      states = []
      fiber1 = Fiber.new { states << :fiber1 }
      fiber2 = Fiber.new { states << :fiber2_start; fiber1.transfer; states << :fiber2_end}
      fiber2.resume.should == [:fiber2_start, :fiber1]
      fiber2.transfer.should == [:fiber2_start, :fiber1, :fiber2_end]
    end

    ruby_bug "#1548", "1.9.2" do
      it "raises a FiberError when transferring to a Fiber which resumes itself" do
        fiber = Fiber.new { fiber.resume }
        lambda { fiber.transfer }.should raise_error(FiberError)
      end
    end  
  end
end
end