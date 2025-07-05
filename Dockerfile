FROM perldocker/perl-tester:5.40

# Install system dependencies
RUN apt-get update && apt-get install -y vim

# Set working directory
WORKDIR /app

# Clone and set up the project
COPY . .

# Install vim-perl
RUN cd inc/vim-perl && make install

# Install Perl dependencies from cpanfile
RUN cpm install -g --cpanfile=cpanfile --with-develop

# Install forked WWW-AdventCalendar
RUN cd inc/WWW-AdventCalendar && \
    dzil authordeps | xargs cpm install -g && \
    dzil install

# Install forked Pod-Elemental-Transformer-SynHi
RUN cd inc/Pod-Elemental-Transformer-SynHi && \
    dzil authordeps | xargs cpm install -g && \
    dzil install

# Install forked PPI-HTML
RUN cd inc/PPI-HTML && \
    perl -I. Makefile.PL && \
    make install
