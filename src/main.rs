use chrono::Utc;
use chrono_tz::Tz;
use std::thread;
use std::time::Duration;
use std::fs::File;
use std::path::Path;
use std::io::{BufWriter, Write};
use signal_hook::iterator::Signals;
use std::sync::{Arc, Mutex};

struct FileWriter {
    buffer: BufWriter<File>,
}

impl FileWriter {
    // Create a new instance of FileWriter for a given file path
    pub fn new(file_path: &Path) -> Result<Self, std::io::Error> {
        let file = File::create(file_path)?;
        let buffer = BufWriter::new(file);
        Ok(FileWriter { buffer })
    }

    // Write data to the file using the buffer
    pub fn write_data(&mut self, data: &str) -> Result<(), std::io::Error> {
        self.buffer.write_all(data.as_bytes())?;
        self.buffer.flush()?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_tz() {
        assert_eq!(get_timezone(), "America/Los_Angeles".parse().expect("tz error"));
        //assert_eq!(get_filepath(), Path::new("/tmp/currentCount.out"));
    }
}

fn get_timezone() -> Tz {
    let timezone: Tz = "America/Los_Angeles".parse().expect("Invalid Timezone");
    timezone
}


fn main() {
    let filepath = Path::new("/tmp/currentCount.out");
    let file_writer = Arc::new(Mutex::new(FileWriter::new(filepath)
    .expect("Failed to create FileWriter")));
    let signal_writer = file_writer.clone();

    //Define counter var and timezone
    let mut counter = 0;
    let timezone: Tz = get_timezone();

    //Define signals iterator and spawn thread to observe signals
    let mut signals = Signals::new(&[signal_hook::consts::SIGTERM, signal_hook::consts::SIGINT])
        .expect("Error creating signal iterator");
    std::thread::spawn(move || {
        let mut signal_message = String::new();
        for signal in signals.forever() {
            match signal {
                signal_hook::consts::SIGTERM => {
                    signal_message = "Received SIGTERM, exiting".to_string();
                }
                signal_hook::consts::SIGINT => {
                    signal_message = "Recieved SIGINT, exiting".to_string();
                }
                _ => println!("Recieved {}", signal)
            }
            println!("{}", signal_message);
            let exit_string = format!(
                "AJ: {} {}\n",
                Utc::now().with_timezone(&timezone).format("%Y-%m-%d %H:%M:%S"),
                signal_message
            );
            signal_writer.lock().unwrap().write_data(&exit_string).expect("write error");
            std::process::exit(0);
                }
            });

    loop {
        let data = format!(
            "AJ: {} #{}\n",
            Utc::now().with_timezone(&timezone).format("%Y-%m-%d %H:%M:%S"),
            counter
        );
        print!("{}", data);

        file_writer.lock().unwrap().write_data(&data).expect("write error");

        //Sleep one second and iterate counter variable
        thread::sleep(Duration::from_secs(1));
        counter += 1;
    }
}
