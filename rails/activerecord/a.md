# 子レコードのデータも一緒に作成する場合の Tips
発行するSQLをなるべく少なくするために、親レコードを作成した後に子レコードを作成する場合は、以下のようにすると良い。

# Bad
- 以下だと、`@parent_model.save!` で作成されるレコードは `ParentModel.new` の箇所だけで、これコードは作成されない
  - newしただけで、saveされていないので、作成されずにただインスタンスだけが作成された状態
```ruby
@parent_model = Parent.new(
  # ...
)

some_array.each do |data|
  ChildModels.new(
    parent_model: @parent_model,
    # ...その他のカラム
  )
end

@parent_model.save!
```

# Good
- `@parent_model.child_models.new` とすると、`@parent_model.save!` で作成されるレコードは 親レコード と 子レコード の両が作成される
```ruby
@parent_model = Parent.new(
  # ...
)

some_array.each do |data|
  @parent_model.child_models.new(
    # ...その他のカラム
  )
end

@parent_model.save!
```
