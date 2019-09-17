class Head
  include Mongoid::Document
  include Mongoid::Alize

  if Mongoid::Compatibility::Version.mongoid4_or_newer?
    include Mongoid::Attributes::Dynamic
  end

  field :size, type: Integer
  field :weight

  if Mongoid::Compatibility::Version.mongoid6_or_newer?
    # to whom it's attached
    belongs_to :person, optional: true, :inverse_of => :heads

    # in whose possession it is
    belongs_to :captor, :class_name => "Person", :inverse_of => :heads, optional: true
  else
    # to whom it's attached
    belongs_to :person

    # in whose possession it is
    belongs_to :captor, :class_name => "Person", :inverse_of => :heads
  end

  # who'd otherwise like to possess it
  has_and_belongs_to_many :wanted_by, :class_name => "Person", :inverse_of => :wants

  # who it sees
  has_many :sees, :class_name => "Person", :inverse_of => :seen_by

  # a relation with no inverse
  has_many :admirer, :class_name => "Person", :inverse_of => nil

  if Mongoid::Compatibility::Version.mongoid6_or_newer?
    # a polymorphic one-to-one relation
    belongs_to :nearest, :polymorphic => true, optional: true

    # a polymorphic one-to-many relation
    has_many :below_people, :class_name => "Person", :as => :above
  else
    # a polymorphic one-to-one relation
    belongs_to :nearest, :polymorphic => true
    
    # a polymorphic one-to-many relation
    has_many :below_people, :class_name => "Person", :as => :above
  end

  def density
    "low"
  end

  # example of one way to handling attribute selection
  # for polymorphic associations or generally using the proc fields option
  def alize_fields(inverse)
    if inverse.is_a?(Person)
      [:name, :location]
    else
      [:id]
    end
  end
end
