FROM --platform=linux/arm64 ubuntu:latest
RUN apt-get update

# Get Ubuntu packages
RUN apt-get install -y \
    build-essential \
    curl

# Update new packages
RUN apt-get update

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

#RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH="/root/.cargo/bin:${PATH}"

COPY . /home
WORKDIR /home

# Build the application
RUN cargo build --release

# Start the application
CMD ["./target/release/counter"]
