# コールバック周りのTips

## `skip_〇〇_action`
親クラスで定義されているコールバックをスキップすることができる

```ruby
# parent_controller.rb
class ParentController < ApplicationController
  before_action :hoge

  def hoge
    puts 'hoge'
  end
end

# child_controller.rb
class ChildController < ParentController
  # hoge メソッドは実行されない
  skip_before_action :hoge

  def index
    puts 'index'
  end
end
```
