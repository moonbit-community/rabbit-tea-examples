///|
fnalias @html.div

///|
typealias @tea.Cmd

///|
enum Message {}

///|
struct Model {}

///|
fn update(msg : Message, model : Model) -> (Cmd[Message], Model) {
  (@tea.none(), model)
}

///|
let svg =
  #| <?xml version="1.0" encoding="UTF-8"?><svg width="16" height="16" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M9 18V42H39V18L24 6L9 18Z" fill="none" stroke="#4a4a4a" stroke-width="4" stroke-linecap="butt" stroke-linejoin="miter"/><path d="M19 29V42H29V29H19Z" fill="none" stroke="#4a4a4a" stroke-width="4" stroke-linejoin="miter"/><path d="M9 42H39" stroke="#4a4a4a" stroke-width="4" stroke-linecap="butt"/></svg>

///|
fn view(model : Model) -> @html.Html[Message] {
  div([@svg.from_string(svg)])
}

///| NOTE: This program is only available in the js backend, 
/// see README.md to getting started.
fn main {
  let model = Model::{  }
  @tea.startup(model~, update~, view~)
}
