# Coding Standards

## Style

* **High Standards**: Write code that is clean, readable, and a pleasure to read.
* **Collaboration**: Discuss code, ask questions, and use Pull Requests to address code smells.
* **Consistency**: When unsure, look for similar code in the project for inspiration.

## Methods ordering

We order methods in classes in the following order:

1. `class` methods
2. `public` methods with `initialize` at the top.
3. `private` methods

## Invocation order

Order methods vertically by invocation order.

```ruby
class SomeClass
  def some_method
    method_1
    method_2
  end

  private

  def method_1
    method_1_1
    method_1_2
  end

  def method_1_1
    # ...
  end

  def method_1_2
    # ...
  end

  def method_2
    method_2_1
    method_2_2
  end

  def method_2_1
    # ...
  end

  def method_2_2
    # ...
  end
end
```

## To bang or not to bang

We use `do_something!` when the method can raise an error.

## Class definitions

We prefer compact class syntax over nested module names for clarity and conciseness.

```ruby
# Bad
module My
  module Namespace
    class SomeClass
      # ...
    end
  end
end

# Good
class My::Namespace::SomeClass
  # ...
end
```

Use nested syntax only when you need to define multiple classes within the same module in a single file, or when you need to add module-level code.

## Routing

We prefer using the `resources` syntax to define routes. This ensures we follow standard RESTful conventions. Custom actions within resources are acceptable, but you should avoid defining standalone routes manually.

```ruby
# Bad
get 'articles', to: 'articles#index'
post 'articles/:id/publish', to: 'articles#publish'

# Good
resources :articles do
  member do
    post :publish
  end
end
```

## Run async operations in jobs

* **Shallow Jobs**: Delegate logic to domain models.
* **Naming**: Use `_later` for methods that enqueue a job, and `_now` for the regular synchronous method.

```ruby
module My::Model::Processing
  extend ActiveSupport::Concern

  included do
    after_create_commit :process_later
  end

  def process_later
    My::Model::ProcessJob.perform_later(self)
  end

  def process_now
    # ...
  end
end

class My::Model::ProcessJob < ApplicationJob
  def perform(model)
    model.process_now
  end
end
```
