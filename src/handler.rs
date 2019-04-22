//use args;
use neovim_lib::{Handler, RequestHandler, Value};
use std::sync::mpsc;

pub mod args {
    use neovim_lib::Value;
    pub fn parse_string(value: &Value) -> Result<String, String> {
        value
            .as_str()
            .ok_or("cannot parse error".to_owned())
            .map(|s| String::from(s))
    }

    pub fn parse_usize(value: &Value) -> Result<usize, String> {
        value
            .as_u64()
            .ok_or("cannot parse usize".to_owned())
            .map(|n| n as usize)
    }
}

pub mod event {

    use std::fmt;
    pub enum Event {
        CursorMovedI {
            line: usize,
            column: usize,
        },
        InsertEnter {
            mode: String,
            line: usize,
            column: usize,
        },
        InsertLeave,
        Quit,
    }

    impl fmt::Debug for Event {
        fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
            use Event::*;

            match self {
                &CursorMovedI {
                    ref line,
                    ref column,
                } => write!(
                    f,
                    "Event::CursorMovedI{{ line: {}, column: {} }}",
                    line, column
                ),
                &InsertEnter {
                    ref mode,
                    ref line,
                    ref column,
                } => write!(
                    f,
                    "Event::InsertEnter{{ mode: {}, line: {}, column: {}}}",
                    mode, line, column
                ),
                &InsertLeave => write!(f, "Event::InsertLeave"),
                &Quit => write!(f, "Event::Quit"),
            }
        }
    }

}

pub struct NeovimHandler(pub mpsc::Sender<event::Event>);

impl NeovimHandler {
    pub fn parse_cursor_moved_i(&mut self, args: &Vec<Value>) -> Result<event::Event, String> {
        if 2 != args.len() {
            return Err(format!(
                "Wrong number of arguments for 'CursorMoveI'.  Expected 2, found \
                 {}",
                args.len()
            ));
        }

        let line = args::parse_usize(&args[0])?;
        let column = args::parse_usize(&args[1])?;

        Ok(event::Event::CursorMovedI {
            line: line,
            column: column,
        })
    }

    pub fn parse_insert_enter(&mut self, args: &Vec<Value>) -> Result<event::Event, String> {
        if 3 != args.len() {
            return Err(format!(
                "Wrong number of arguments for 'InsertEnter'.  Expected 3, found \
                 {}",
                args.len()
            ));
        }

        let mode = args::parse_string(&args[0])?;
        let line = args::parse_usize(&args[1])?;
        let column = args::parse_usize(&args[2])?;

        Ok(event::Event::InsertEnter {
            mode: mode,
            line: line,
            column: column,
        })
    }
}

impl Handler for NeovimHandler {
    fn handle_notify(&mut self, name: &str, args: Vec<Value>) {
        info!("event: {}", name);

        //print_args(&args);
        match name {
            "cursor-moved-i" => {
                if let Ok(event) = self.parse_cursor_moved_i(&args) {
                    info!("cursor moved i: {:?}", event);
                    if let Err(reason) = self.0.send(event) {
                        error!("{}", reason);
                    }
                }
            }
            "insert-enter" => {
                if let Ok(event) = self.parse_insert_enter(&args) {
                    info!("insert enter: {:?}", event);
                    if let Err(reason) = self.0.send(event) {
                        error!("{}", reason);
                    }
                }
            }
            "insert-leave" => {
                if let Err(reason) = self.0.send(event::Event::InsertLeave) {
                    error!("{}", reason);
                }
            }
            "quit" => {
                if let Err(reason) = self.0.send(event::Event::Quit) {
                    error!("{}", reason);
                }
            }
            _ => {}
        }
    }
}
impl RequestHandler for NeovimHandler {
    fn handle_request(&mut self, _name: &str, _args: Vec<Value>) -> Result<Value, Value> {
        Err(Value::from("not implemented"))
    }
}
