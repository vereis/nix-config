# Elixir-Specific Refactoring Guidance

Additional considerations when refactoring Elixir code.

## Inlining & Private Functions

**Default to inlining private functions.** Only extract when there's genuine reuse.

Inline when:
- Function is only called once
- Function body is short and the name doesn't add clarity
- You're jumping through multiple private functions to understand simple flow
- The extraction was done for "clean code" reasons rather than practical ones

Keep extracted when:
- Genuinely reused in multiple places
- Required for recursion
- Significantly clarifies complex logic (rare)

```elixir
# Bad: unnecessary extraction
defp validate_email(email), do: String.contains?(email, "@")

def register(email) do
  if validate_email(email), do: {:ok, email}, else: {:error, :invalid}
end

# Good: inline it
def register(email) do
  if String.contains?(email, "@"), do: {:ok, email}, else: {:error, :invalid}
end
```

**Primary metric: reduce nesting depth.** If extracting a function reduces nesting, it might be worth it. If it just moves code around, inline it.

## Control Flow Preferences

Prefer in this order: **pattern matching > cond > with > if**

### Pattern Matching First

Use multi-clause functions and pattern match on structs for operation-primal design:

```elixir
# Good: operation-primal via pattern matching
def calculate_area(%Circle{radius: r}), do: :math.pi() * r * r
def calculate_area(%Rectangle{width: w, height: h}), do: w * h
def calculate_area(%Triangle{base: b, height: h}), do: 0.5 * b * h

# Bad: operand-primal via protocols (unless you genuinely need open extension)
defprotocol Shape do
  def area(shape)
end
```

### Custom Guards

Define custom guards for complex conditions instead of inline logic:

```elixir
# Good: named guard clarifies intent
defguard is_adult(age) when is_integer(age) and age >= 18

def can_vote(%User{age: age}) when is_adult(age), do: true
def can_vote(_user), do: false

# Bad: inline guard logic
def can_vote(%User{age: age}) when is_integer(age) and age >= 18, do: true
```

### Prefer `cond` Over `with`/`if`

`cond` keeps all conditions visible in one place:

```elixir
# Good: all conditions visible, easy to add more
def authorize(user, resource) do
  cond do
    is_nil(user) ->
      {:error, :unauthenticated}

    user.role != :admin and resource.private ->
      {:error, :unauthorized}

    user.org_id != resource.org_id ->
      {:error, :unauthorized}

    true ->
      {:ok, resource}
  end
end

# Bad: nested with/if obscures control flow
def authorize(user, resource) do
  with {:ok, user} <- validate_user(user),
       {:ok, _} <- check_admin_or_public(user, resource),
       {:ok, _} <- check_org_match(user, resource) do
    {:ok, resource}
  end
end
```

### When `with` is Appropriate

Use `with` for sequential operations that short-circuit on error, **without complex else blocks**:

```elixir
# Good: simple short-circuit, no else block
def create_order(attrs) do
  with {:ok, user} <- fetch_user(attrs.user_id),
       {:ok, product} <- fetch_product(attrs.product_id),
       {:ok, order} <- Orders.create(user, product, attrs) do
    {:ok, order}
  end
end

# Bad: complex else block - use case instead
def create_order(attrs) do
  with {:ok, user} <- fetch_user(attrs.user_id),
       {:ok, product} <- fetch_product(attrs.product_id) do
    Orders.create(user, product, attrs)
  else
    {:error, :user_not_found} -> {:error, "User not found"}
    {:error, :product_not_found} -> {:error, "Product not found"}
    {:error, changeset} -> {:error, format_errors(changeset)}
  end
end

# Bad: tagging pattern - never do this
with {:user, {:ok, user}} <- {:user, fetch_user(id)},
     {:product, {:ok, product}} <- {:product, fetch_product(id)} do
  # ...
end
```

### Avoid `if` When Possible

`if` should be rare. Prefer pattern matching or `cond`:

```elixir
# Bad: if statement
def process(item) do
  if item.type == :special do
    handle_special(item)
  else
    handle_normal(item)
  end
end

# Good: pattern matching
def process(%{type: :special} = item), do: handle_special(item)
def process(item), do: handle_normal(item)
```

## Pipe Operator Guidelines

Pipes are for **pure data transformations only**.

### When to Use Pipes

```elixir
# Good: pure transformation chain
users
|> Enum.filter(&active?/1)
|> Enum.map(&format_user/1)
|> Enum.sort_by(& &1.name)
```

### When NOT to Use Pipes

**Never pipe error tuples:**

```elixir
# Bad: spreading error handling across functions
attrs
|> validate_required()
|> validate_email()
|> create_user()
|> send_welcome_email()

# Where each function handles {:ok, _} | {:error, _}
defp validate_email({:ok, attrs}), do: ...
defp validate_email({:error, _} = err), do: err  # Boilerplate!

# Good: use with for error handling
with {:ok, attrs} <- validate_required(attrs),
     {:ok, attrs} <- validate_email(attrs),
     {:ok, user} <- create_user(attrs) do
  send_welcome_email(user)
end
```

**Don't hide higher-order functions:**

```elixir
# Bad: hiding the Enum operation
def process(items) do
  items
  |> parse_items()
  |> sum_items()
end

defp parse_items(list), do: Enum.map(list, &String.to_integer/1)
defp sum_items(list), do: Enum.sum(list)

# Good: expose the higher-order functions
def process(items) do
  items
  |> Enum.map(&String.to_integer/1)
  |> Enum.sum()
end
```

## Error Handling Philosophy

### Let It Crash

Use assertive pattern matching. Crash on unexpected data:

```elixir
# Good: crash if data doesn't match expectations
def process_response(%{"status" => "ok", "data" => data}) do
  # Only handles the expected case
  transform(data)
end

# Good: use bang functions when errors are exceptional
def fetch_config! do
  data = File.read!(config_path())
  Jason.decode!(data)
end

# Bad: defensive programming that hides bugs
def process_response(response) do
  case Map.get(response, "status") do
    "ok" -> {:ok, Map.get(response, "data")}
    _ -> {:error, :unknown}  # What went wrong? Who knows!
  end
end
```

### Only Return Error Tuples When Caller Can Handle Them

```elixir
# Bad: forcing caller to handle unrecoverable error
def get_from_cache(key) do
  try do
    :ets.lookup(:cache, key)
  catch
    _, _ -> {:error, "Cache unavailable"}  # Caller can't fix this!
  end
end

# Good: let it crash - caller can't do anything anyway
def get_from_cache(key) do
  :ets.lookup(:cache, key)
end
```

### Assertive Map/Struct Access

Use `map.key` when key must exist, `map[:key]` when optional:

```elixir
# Good: assertive access for required fields
def format_user(%User{} = user) do
  "#{user.name} <#{user.email}>"  # Crashes if fields missing
end

# Good: bracket access for optional fields
def format_user(%User{} = user) do
  name = user.name
  nickname = user[:nickname] || name  # Optional field
  "#{nickname} (#{name})"
end
```

## Type Specifications

**Typespecs for EVERY public function.** No exceptions.

```elixir
defmodule Orders do
  @type order :: %__MODULE__{
    id: pos_integer(),
    user_id: pos_integer(),
    total: Decimal.t(),
    status: status()
  }

  @type status :: :pending | :confirmed | :shipped | :delivered

  @spec create(User.t(), map()) :: {:ok, order()} | {:error, Ecto.Changeset.t()}
  def create(%User{} = user, attrs) when is_map(attrs) do
    # ...
  end

  @spec confirm(order()) :: {:ok, order()} | {:error, :already_confirmed}
  def confirm(%__MODULE__{status: :pending} = order) do
    # ...
  end
end
```

Use custom types for domain concepts. Run dialyzer.

## Performance Patterns

### Avoid Hidden O(n) Operations

```elixir
# Bad: length/1 is O(n), called in guard
def process(items) when length(items) > 0 do
  # ...
end

# Good: pattern match instead
def process([_ | _] = items) do
  # ...
end
def process([]), do: {:error, :empty}
```

### Lift Nested Operations Out of Loops

```elixir
# Bad: O(n^2) - nested find for each user
users
|> Enum.map(fn user ->
  dept = Enum.find(departments, &(&1.id == user.dept_id))
  %{user | department: dept}
end)

# Good: O(n) - build lookup map first
dept_map = Map.new(departments, &{&1.id, &1})

users
|> Enum.map(fn user ->
  %{user | department: Map.get(dept_map, user.dept_id)}
end)
```

### Use MapSet for Membership Checks

```elixir
# Bad: O(n) membership check in loop
allowed = ["active", "pending", "verified"]
Enum.filter(items, &(&1.status in allowed))

# Good: O(1) membership check
allowed = MapSet.new(["active", "pending", "verified"])
Enum.filter(items, &MapSet.member?(allowed, &1.status))
```

### List Building

```elixir
# Bad: O(n^2) due to ++ on left side
Enum.reduce(items, [], fn item, acc ->
  acc ++ [transform(item)]
end)

# Good: O(n) - prepend then reverse
items
|> Enum.reduce([], fn item, acc -> [transform(item) | acc] end)
|> Enum.reverse()
```

### Compile Regex at Module Level

```elixir
# Bad: compiles regex on every call
def extract_emails(text) do
  Regex.scan(~r/\w+@\w+\.\w+/, text)
end

# Good: compile once
@email_regex ~r/\w+@\w+\.\w+/
def extract_emails(text) do
  Regex.scan(@email_regex, text)
end
```

### Batch Operations

```elixir
# Bad: N database calls
def create_activities(attrs_list) do
  Enum.map(attrs_list, &Repo.insert(Activity.changeset(%Activity{}, &1)))
end

# Good: single database call
def create_activities(attrs_list) do
  entries = Enum.map(attrs_list, &Map.put(&1, :inserted_at, DateTime.utc_now()))
  Repo.insert_all(Activity, entries)
end
```

### Stream Large Datasets

```elixir
# Bad: loads entire table into memory
def export_users do
  Repo.all(User)
  |> Enum.map(&format_row/1)
  |> Enum.join("\n")
end

# Good: stream processing
def export_users do
  Repo.transaction(fn ->
    User
    |> Repo.stream()
    |> Stream.map(&format_row/1)
    |> Enum.join("\n")
  end)
end
```

## Comment Quality

Same as general guidance, but Elixir-specific:

- Use `@moduledoc` and `@doc` for documentation, not comments
- `@doc false` for private-ish public functions (callbacks, etc.)
- Comments for *why*, never *what*

```elixir
# Bad: comment explains what code does
# Check if user is an admin
def admin?(%User{role: :admin}), do: true
def admin?(_), do: false

# Good: no comment needed, code is clear
def admin?(%User{role: :admin}), do: true
def admin?(_), do: false

# Good: comment explains WHY
# We check org_id equality manually because the DB query
# would require a join that breaks our query planner
def same_org?(%User{org_id: org_id}, %Resource{org_id: org_id}), do: true
def same_org?(_, _), do: false
```

## Testing Patterns

### Use `for` in Tests for Better Failure Messages

```elixir
# Bad: unhelpful failure message
assert Enum.all?(posts, &match?(%Post{}, &1))

# Good: shows exactly which element failed
for post <- posts, do: assert %Post{} = post
```

### Test Behavior, Not Implementation

```elixir
# Bad: testing implementation details
test "creates user with hashed password" do
  {:ok, user} = Users.create(%{password: "secret"})
  assert user.password_hash == Bcrypt.hash("secret")  # Tied to impl
end

# Good: testing behavior
test "created user can authenticate with password" do
  {:ok, user} = Users.create(%{email: "test@example.com", password: "secret"})
  assert {:ok, ^user} = Users.authenticate("test@example.com", "secret")
end
```
