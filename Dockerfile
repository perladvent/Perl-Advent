FROM perldocker/perl-tester:5.40

# Install system dependencies
RUN apt-get update && apt-get install -y vim git

# Set working directory
WORKDIR /app

# Copy only dependency-related files first (for layer caching)
COPY cpanfile ./
COPY inc/ ./inc/

# Initialize git repo to satisfy Dist::Zilla's git checks
# The broken .git worktree pointers prevent dzil from working properly
RUN rm -rf .git inc/*/.git && \
    git init && \
    git config user.email "docker@build" && \
    git config user.name "Docker Build" && \
    git add . && \
    git commit -m "Initial commit for build"

# Install vim-perl to system-wide location
RUN cd inc/vim-perl && make install PREFIX=/usr/share/vim/vimfiles

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

# Remove the temporary git repo before copying the rest of the application
RUN rm -rf /app/.git /app/inc/*/.git

# Copy the rest of the application
# This layer will invalidate on any source change, but dependencies above are cached
COPY . .
