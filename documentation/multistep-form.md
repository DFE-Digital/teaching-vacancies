# Multistep form

Multistep form is a mini-library aiming at reducing the complexity of long user journeys consisting of multiple steps.

While many libraries exist for that reason already, they are all quite limited and require a number of hacks in order to, for example, create dynamic step orders. This usually leads to really difficult to read and maintain source code as the smallest change has unexpected consequences.

## How is it different

This library is based on dynamic step ordering and, hopefully, handles a number of common but yet interesting edge-cases, like user resubmitting one of the steps making other steps invalid.

The library is still work in progress!

## Multstep::Form

To use multistep, you need to create a new class and include `Multistep::Form` module. Then simply define steps as isolated form objects:

```ruby
require 'multistep/form'

class MyMultistepForm
  include Multistep::Form

  attribute :company_id
  
  step :name do
    attribute :first_name
    attribute :last_name

    validates :first_name, :last_name, presence: true
  end

  step :contact do
    attribute :email
    attribute :lists, array: true

    validates :email, presence: true
  end
  
  step :another_step do
    attribute :some_attribute
  end
end
```

### Attributes
Attributes can be defined both within steps and within the Multistep object. Attributes represents the state of the form and all steps' attributes are automatically accessible on the multistep form object itself:

```ruby
form = MyMultistepForm.new
form.attributes #=> { company_id: nil, first_name: nil, last_name: nil, email: nil, lists: [], attribute: nil, completed_steps: {}}
form.first_name = 'Stan'
form.first_name #=> 'Stan'
```

All the multistep form comes with a built-in attribute `completed_steps` which is relied upon by many of the internal methods.

`#attributes` method is later used to save the state of the form - see controller section of this doc.


Each step is represented by a standalone form object and can be accessed via `steps` method:

```ruby
form.steps[:name].attributes #=> { first_name: 'Stan', last_name: nil }
form.steps[:name].valid? #=> false
```

You can also access the step classes via `MyMultistepForm.steps`:

```ruby
MyMultistepForm.steps #=> { name: MyMultipleForm::Name, contact: MyMultipleForm::Contact, another_step: MyMultipleForm::AnotherStep }
```

##### Arrays
In addition to standard `ActiveModel.attribute` usage, you can also denote attribute to be an array. This will:
* sets `[]` as a default
* automatically reject all blank values on assignment to handle html form parameters.

```ruby
class SmallForm
  include Multistep::Form
  
  attribute :ids, array: true
end

form = SmallForm.new
form.ids #=> []
form.assign_attributes(ids: ["", "5", "17"])
form.ids #=> ["5", "17"]

```

TODO: `attribute` method accepts typecasts argument as well, which is currently ignored for arrays. Would be nice to be able to declare attributes like:

```ruby
attribute :numbers, :integer, array: true # This currently ignores :integer casting
```

### Flow control

Unlike most of the multistep forms libraries, we make very little assumptions about the order of the steps. The flow is defined by the `#next_step` method, which determines the next step of the form based on the current state of the form.
The counterpoint to `next_step` method is `complete_step!` which updates the state of the form. 
The default implementation of `next_step` methods simply assumes the linear order of the steps, in the order of their definitions:

```ruby
form = MyMultistepForm.new
form.next_step #=> :name
form.complete_step!(:name)

form.next_step #=> :contact
```

However, it is important to note that steps can be completed in any order. Form will find its way around this:

```ruby
form = MyMultistepForm.new
form.complete_step!(:contact)
form.next_step #=> :name
form.complete_step!(:name)
form.next_step #=> :another_step
```

This means, we can override the `next_step` method to handle more interesting flows, like random order below:

```ruby
class MyMultistepForm
  def next_step(current_step: nil, **)
    super if current_step.present?
    
    @next_step ||= (self.class.steps.keys - completed_steps.keys).sample
  end
  
  def complete_step!(*)
    super
    @next_step = nil
  end
end
 
```
NOTE: In above example we have fixed next_step so it returns the same, albeit random, value of the next step until the step is completed.

NOTE2: `next_step` takes an optional `current_step:` keyword. When specified, method is suppose to return the step occurring after given, already completed step and its result should depend solely on order of `complete_step!` calls. The original method is quite complex (as it needs to take care of skipped steps, which suddenly should no longer be skipped etc), so we simply call super method in case `current_step` keyword is explicitly passed.

```ruby
form = MyMultistepForm.new
form.next_step #=> :contact (random)
form.complete_step(:contact)
form.next_step #=> :another_step (random)
form.complete_step
```

### Navigating back

Multistep object also implements `previous_step`, which required a single keyword of `current_step`, which must be either a completed step or `next_step` of the form - this is why it was important earlier to fix value of `next_step` in a random order example.
`previous_step`, similarly to `next_step(current_step:)` relies solely on the order of step completion.

You can also test if given step has been completed or not using `completed?` method.

### Steps

As mentioned earlier, each step is a standalone form object, however due to an upcoming deadline it is not as isolated as it should be. :( 
Each step instance can access its multistep parent, using `multistep` call. This might be useful if the form options are dependant on previous user's answers.

In addition to this, each step implements two magic method: `skip?` and `invalidate?`.

#### skip?

When you invoke `complete_step!` method, it will test the `skip?` method of the `next_step` - if it is truthy it marks that step as skipped. The process repeats until it finds a non-skippable step or until `next_step` returns `nil`.
```ruby
class SomeForm
  include Multistep::Form
  
  step :first do
    attribute :name
  end
  
  step :provide_contact do
    attribute :provide_contact, :boolean
  end
  
  step :contact do
    attribute :email
    attribute :phone
    
    def skip?
      !multistep.provide_contact
    end
  end
  
  step :final_step
end

form = SomeForm.new
form.complete_step!(:name)

form.assign_attributes(provide_contact: '0')
form.complete_step!(:provide_contact)

form.completed_steps #=> { :first => :completed, :provide_contact => :completed, :contact => :skipped }
form.next_step #=> :final_step

form.assign_attributes(provide_contact: '1')
form.next_step #=> :contact
```

NOTE: There might be an argument if we should require another call to `complete_step!` between the last two lines. This would likely reduce complexity of the `next_step` method, pushing all state changes of the steps onto `complete_step!` method.

#### invalidate?

When some step is being re-submitted, `complete_step!` will loop over all the steps after that step in its linear completion history and invoke `invalidate?` method. As this happens before the form is saved (see controller), you will have access to all the methods from `ActiveModel::Dirty` module to decide whether or not given step needs to be invalidated.
As an example, here's the `invalidate?` method of the Jobseekers::JobPreferencesForm::KeyStages:

```ruby
def options(phases: multistep.phases)
  # generates array of options depending on user's previous answer to `phases`
end

def invalidate?
  return false unless multistep.phases_changed?

  options_before, options_after = multistep.changes[:phases].map { |phases| options(phases: phases).keys }
  self.key_stages = key_stages & options_after

  any_new_option = (options_after - options_before).any?
  any_new_option || key_stages.blank?
end
```

As you can see, the step will be invalidated if the user changes his previous `phases` selection which will either result in new options for users to select from or if it will remove all the previously selected key_stages value.

Invalidated step keeps it's place in the committed history, but is no longer treated as completed and will be picked up by `next_step` method.

### Completing the journey

Each multistep form implements `complete!` method, which is to be executed once all the required information is gathered.

### Misc

If you ever need to find a step which is responsible for setting given attribute, you can use `.delegated_attributes` method on the form class:

```ruby
MyMultistepForm.delegated_attributes[:first_name] #=> :name
```

## Controller

To use your multistep form object, create a new controller, include `Multistep::Controller` module and add some configuration:

```ruby
class MyController < ApplicationController
  include Multistep::Controller
  
  multistep_form MyMultistepForm, key: :my_form
  escape_path { root_path }
end
```

The above is the minimal setup for the controller. `multistep_form` defines the form object to use, together with the param key data will be available from: `params.require(:my_form)` 
`escape_path` defines the path which will be used when user cancels the flow or as a back_path from the first step.

Controller defines three action, `start`, `edit` and `update`. By default:
* `start` will create and store new instance of the form and then redirect to the first step.
* `edit` action requires a `step` param - it then sets the `@step` variable to the step form and renders the view matching the step name. 
* `update` will validate the form and render the form if there are any errors. Otherwise, it will complete the step, store the form and proceed to next step. If there's no next step, it will invoke controller's `complete` method

By default `complete` method calls `form.complete!` and redirects to escape_path. This method can be overriden in order of adding flash message or change the redirection path. 

### Modifying behaviour on step completion

You can also define custom code to execute when the step is completed using:

```ruby
on_completed(:name) do |form|
  return unless form.first_name == 'Stan'
  
  flash[:error] = 'Nice try!'
  redirect_to not_allowed_path
end
```

If no action is specified in the hook, the hook will be executed and then user will be redirected to next step.

### Storage

By default, form is stored within a session. This is based on assumption that majority of multistep forms operate on collect/complete basis. There are two methods which can be overriden in order to modify the form storage: `store_form!` and `attributes_from_store`.

```ruby
def storage_record
  @storage_record ||= SomeRecord.find_or_initialize_by(user_id: current_user.id)
end

def store_form!
  storage_record.assign_attributes(form.attributes)
end

def attributes_from_storage
  storage_record.attributes.symbolize_keys.without(:created_at, :updated_at)
end
```

One thing to remember is that `start` action invokes `store_form!`, so you might want to override it as well.

### Routes

All you need is to define routes for the three actions:

```ruby
scope controller: 'my_controller', path: 'my-form' do
  get '', action: :start
  get ':step', action: :edit
  post ':step', action: :update  
end
```

## Final notes

The `next_step` method is crying for some refactor. For example, our "random" definition completely ignores skippable steps (see Steps section) and it is unreasonable to expect user of the library to know all those details - which is a sure way of introducing a bug. I'd propose the `next_step` without the argument to be extracted to another method, maybe `caluclate_next_step` which is expected to be overriden and is used within a `next_step` method, which should never needed to be touched.
