///|
enum Model {
  Loading
  Failed
  Editing(Card)
}

///|
struct Card {
  title : String
  content : String
  id : Int?
} derive(Show)

///|
enum Msg {
  TitleChanged(String)
  ContentChanged(String)
  GotCardData(Result[Card, String])
  SaveCardAndExit(Card)
  ReqResult(Result[Json, String])
} derive(Show)

///|
pub fn load(index : Int?) -> (@tea.Cmd[Msg], Model) {
  match index {
    None => (@tea.none(), Editing({ title: "", content: "", id: None }))
    Some(index) =>
      (
        @http.get(
          "/api/cards/\{index}",
          expect=Json(GotCardData(_), decode_card),
        ),
        Loading,
      )
  }
}

///|
pub fn decode_card(data : Json) -> Result[Card, String] {
  match data {
    { "title": String(title), "content": String(content), "id": Number(id), .. } =>
      Ok({ title, content, id: Some(id.to_int()) })
    _ => Err("Invalid card data")
  }
}

///|
pub fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match (msg, model) {
    (GotCardData(card), _) =>
      match card {
        Ok(card) => (@tea.none(), Editing(card))
        Err(_) => (@tea.none(), Failed)
      }
    (TitleChanged(title), Editing(card)) =>
      (@tea.none(), Editing({ ..card, title, }))
    (ContentChanged(content), Editing(card)) =>
      (@tea.none(), Editing({ ..card, content, }))
    (SaveCardAndExit(card), _) => {
      let save = match card.id {
        Some(id) =>
          if card.title == "" && card.content == "" {
            @http.delete("/api/cards/\{id}", expect=Json(ReqResult(_), Ok(_)))
          } else {
            @http.patch(
              "/api/cards/\{id}",
              Json({
                "title": card.title.to_json(),
                "content": card.content.to_json(),
                "id": id.to_json(),
              }),
              expect=Json(ReqResult(_), Ok(_)),
            )
          }
        None =>
          @http.post(
            "/api/cards",
            Json({
              "title": Json::string(card.title),
              "content": Json::string(card.content),
            }),
            expect=Json(ReqResult(_), Ok(_)),
          )
      }
      let exit = @nav.push_url("/home")
      (@tea.batch([save, exit]), model)
    }
    _ => (@tea.none(), model)
  }
}

///|
pub fn view(model : Model) -> @html.Html[Msg] {
  match model {
    Loading => @html.div([@html.text("Loading card...")])
    Failed => @html.div([@html.text("Failed to load card")])
    Editing({ title, content, id } as card) => {
      let title_text = match id {
        Some(_) => @html.text("Edit Todo")
        None => @html.text("New Todo")
      }
      @html.div(
        style=[
          "display: flex", "flex-direction: column", "width: 500px", "height: 100%",
        ],
        [
          @html.h1([title_text]),
          view_text_input("title", title, input=TitleChanged(_)),
          view_text_input("content", content, input=ContentChanged(_)),
          @views.button("close", click=SaveCardAndExit(card)),
        ],
      )
    }
  }
}

///|
fn[M] view_text_input(
  label : String,
  value : String,
  input~ : (String) -> M
) -> @html.Html[M] {
  @html.div([
    @html.label([
      @html.text(label),
      @html.input(
        style=[
          "border: 1px solid #ccc", "border-radius: 5px", "padding: 5px", "margin: 10px",
          "width: 500px",
        ],
        value~,
        input_type=Text,
        input~,
      ),
    ]),
  ])
}
