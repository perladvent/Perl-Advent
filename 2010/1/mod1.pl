use YAPE::Regex::Explain;

my $RE = qr/[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"[^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"[^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)*@[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)*|(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"[^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[^()<>@,;:".\\\[\]\x80-\xff\000-\010\012-\037]*(?:(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)|"[^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[^()<>@,;:".\\\[\]\x80-\xff\000-\010\012-\037]*)*<[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:@[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)*(?:,[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*@[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)*)*:[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)?(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"[^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"[^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)*@[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)*>)/;

print YAPE::Regex::Explain->new($RE)->explain('regex');

__END__

(?x-ims:               # group, but do not capture (disregarding
                       # whitespace and comments) (case-sensitive)
                       # (with ^ and $ matching normally) (with . not
                       # matching \n):

  [\040\t]*              # any character of: '\040', '\t' (tab) (0 or
                         # more times (matching the most amount
                         # possible))

  (?x:                   # group, but do not capture (0 or more times
                         # (matching the most amount possible)):

    \(                     # '('

    [^\\\x80-              # any character except: '\\', '\x80' to
    \xff\n\015()]*         # '\xff', '\n' (newline), '\015', '(', ')'
                           # (0 or more times (matching the most
                           # amount possible))

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      (?x:                   # group, but do not capture:

        \\                     # '\'

        [^\x80-\xff]           # any character except: '\x80' to
                               # '\xff'

       |                      # OR

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

      )                      # end of grouping

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015()]*         # '\xff', '\n' (newline), '\015', '(',
                             # ')' (0 or more times (matching the
                             # most amount possible))

    )*                     # end of grouping

    \)                     # ')'

    [\040\t]*              # any character of: '\040', '\t' (tab) (0
                           # or more times (matching the most amount
                           # possible))

  )*                     # end of grouping

  (?x:                   # group, but do not capture:

    (?x:                   # group, but do not capture:

      [^(\040)<>@,;:".       # any character except: '(', '\040',
      \\\[\]\000-            # ')', '<', '>', '@', ',', ';', ':',
      \037\x80-\xff]+        # '"', '.', '\\', '\[', '\]', '\000' to
                             # '\037', '\x80' to '\xff' (1 or more
                             # times (matching the most amount
                             # possible))

      (?!                    # look ahead to see if there is not:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-\xff]         # '"', '.', '\\', '\[', '\]', '\000'
                               # to '\037', '\x80' to '\xff'

      )                      # end of look-ahead

     |                      # OR

      "                      # '"'

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015"]*          # '\xff', '\n' (newline), '\015', '"' (0
                             # or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \\                     # '\'

        [^\x80-\xff]           # any character except: '\x80' to
                               # '\xff'

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015"]*          # to '\xff', '\n' (newline), '\015',
                               # '"' (0 or more times (matching the
                               # most amount possible))

      )*                     # end of grouping

      "                      # '"'

    )                      # end of grouping

    [\040\t]*              # any character of: '\040', '\t' (tab) (0
                           # or more times (matching the most amount
                           # possible))

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \(                     # '('

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015()]*         # '\xff', '\n' (newline), '\015', '(',
                             # ')' (0 or more times (matching the
                             # most amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        (?x:                   # group, but do not capture:

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

         |                      # OR

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

        )                      # end of grouping

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

      )*                     # end of grouping

      \)                     # ')'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

    )*                     # end of grouping

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \.                     # '.'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

      (?x:                   # group, but do not capture:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-              # '"', '.', '\\', '\[', '\]', '\000'
        \xff]+                 # to '\037', '\x80' to '\xff' (1 or
                               # more times (matching the most amount
                               # possible))

        (?!                    # look ahead to see if there is not:

          [^(\040)<>@,           # any character except: '(', '\040',
          ;:".\\\[\]\0           # ')', '<', '>', '@', ',', ';', ':',
          00-\037\x80-           # '"', '.', '\\', '\[', '\]', '\000'
          \xff]                  # to '\037', '\x80' to '\xff'

        )                      # end of look-ahead

       |                      # OR

        "                      # '"'

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015"]*          # to '\xff', '\n' (newline), '\015',
                               # '"' (0 or more times (matching the
                               # most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015"]           # to '\xff', '\n' (newline), '\015',
          *                      # '"' (0 or more times (matching the
                                 # most amount possible))

        )*                     # end of grouping

        "                      # '"'

      )                      # end of grouping

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

    )*                     # end of grouping

    @                      # '@'

    [\040\t]*              # any character of: '\040', '\t' (tab) (0
                           # or more times (matching the most amount
                           # possible))

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \(                     # '('

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015()]*         # '\xff', '\n' (newline), '\015', '(',
                             # ')' (0 or more times (matching the
                             # most amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        (?x:                   # group, but do not capture:

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

         |                      # OR

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

        )                      # end of grouping

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

      )*                     # end of grouping

      \)                     # ')'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

    )*                     # end of grouping

    (?x:                   # group, but do not capture:

      [^(\040)<>@,;:".       # any character except: '(', '\040',
      \\\[\]\000-            # ')', '<', '>', '@', ',', ';', ':',
      \037\x80-\xff]+        # '"', '.', '\\', '\[', '\]', '\000' to
                             # '\037', '\x80' to '\xff' (1 or more
                             # times (matching the most amount
                             # possible))

      (?!                    # look ahead to see if there is not:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-\xff]         # '"', '.', '\\', '\[', '\]', '\000'
                               # to '\037', '\x80' to '\xff'

      )                      # end of look-ahead

     |                      # OR

      \[                     # '['

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015\[\]         # to '\xff', '\n' (newline), '\015',
        ]                      # '\[', '\]'

       |                      # OR

        \\                     # '\'

        [^\x80-\xff]           # any character except: '\x80' to
                               # '\xff'

      )*                     # end of grouping

      \]                     # ']'

    )                      # end of grouping

    [\040\t]*              # any character of: '\040', '\t' (tab) (0
                           # or more times (matching the most amount
                           # possible))

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \(                     # '('

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015()]*         # '\xff', '\n' (newline), '\015', '(',
                             # ')' (0 or more times (matching the
                             # most amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        (?x:                   # group, but do not capture:

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

         |                      # OR

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

        )                      # end of grouping

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

      )*                     # end of grouping

      \)                     # ')'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

    )*                     # end of grouping

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \.                     # '.'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

      (?x:                   # group, but do not capture:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-              # '"', '.', '\\', '\[', '\]', '\000'
        \xff]+                 # to '\037', '\x80' to '\xff' (1 or
                               # more times (matching the most amount
                               # possible))

        (?!                    # look ahead to see if there is not:

          [^(\040)<>@,           # any character except: '(', '\040',
          ;:".\\\[\]\0           # ')', '<', '>', '@', ',', ';', ':',
          00-\037\x80-           # '"', '.', '\\', '\[', '\]', '\000'
          \xff]                  # to '\037', '\x80' to '\xff'

        )                      # end of look-ahead

       |                      # OR

        \[                     # '['

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015\[           # to '\xff', '\n' (newline), '\015',
          \]]                    # '\[', '\]'

         |                      # OR

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

        )*                     # end of grouping

        \]                     # ']'

      )                      # end of grouping

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

    )*                     # end of grouping

   |                      # OR

    (?x:                   # group, but do not capture:

      [^(\040)<>@,;:".       # any character except: '(', '\040',
      \\\[\]\000-            # ')', '<', '>', '@', ',', ';', ':',
      \037\x80-\xff]+        # '"', '.', '\\', '\[', '\]', '\000' to
                             # '\037', '\x80' to '\xff' (1 or more
                             # times (matching the most amount
                             # possible))

      (?!                    # look ahead to see if there is not:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-\xff]         # '"', '.', '\\', '\[', '\]', '\000'
                               # to '\037', '\x80' to '\xff'

      )                      # end of look-ahead

     |                      # OR

      "                      # '"'

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015"]*          # '\xff', '\n' (newline), '\015', '"' (0
                             # or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \\                     # '\'

        [^\x80-\xff]           # any character except: '\x80' to
                               # '\xff'

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015"]*          # to '\xff', '\n' (newline), '\015',
                               # '"' (0 or more times (matching the
                               # most amount possible))

      )*                     # end of grouping

      "                      # '"'

    )                      # end of grouping

    [^()<>@,;:".\\\[\]     # any character except: '(', ')', '<',
    \x80-\xff\000-         # '>', '@', ',', ';', ':', '"', '.', '\\',
    \010\012-\037]*        # '\[', '\]', '\x80' to '\xff', '\000' to
                           # '\010', '\012' to '\037' (0 or more
                           # times (matching the most amount
                           # possible))

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      (?x:                   # group, but do not capture:

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

       |                      # OR

        "                      # '"'

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015"]*          # to '\xff', '\n' (newline), '\015',
                               # '"' (0 or more times (matching the
                               # most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015"]           # to '\xff', '\n' (newline), '\015',
          *                      # '"' (0 or more times (matching the
                                 # most amount possible))

        )*                     # end of grouping

        "                      # '"'

      )                      # end of grouping

      [^()<>@,;:".\\\[       # any character except: '(', ')', '<',
      \]\x80-\xff\000-       # '>', '@', ',', ';', ':', '"', '.',
      \010\012-\037]*        # '\\', '\[', '\]', '\x80' to '\xff',
                             # '\000' to '\010', '\012' to '\037' (0
                             # or more times (matching the most
                             # amount possible))

    )*                     # end of grouping

    <                      # '<'

    [\040\t]*              # any character of: '\040', '\t' (tab) (0
                           # or more times (matching the most amount
                           # possible))

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \(                     # '('

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015()]*         # '\xff', '\n' (newline), '\015', '(',
                             # ')' (0 or more times (matching the
                             # most amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        (?x:                   # group, but do not capture:

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

         |                      # OR

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

        )                      # end of grouping

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

      )*                     # end of grouping

      \)                     # ')'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

    )*                     # end of grouping

    (?x:                   # group, but do not capture (optional
                           # (matching the most amount possible)):

      @                      # '@'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

      (?x:                   # group, but do not capture:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-              # '"', '.', '\\', '\[', '\]', '\000'
        \xff]+                 # to '\037', '\x80' to '\xff' (1 or
                               # more times (matching the most amount
                               # possible))

        (?!                    # look ahead to see if there is not:

          [^(\040)<>@,           # any character except: '(', '\040',
          ;:".\\\[\]\0           # ')', '<', '>', '@', ',', ';', ':',
          00-\037\x80-           # '"', '.', '\\', '\[', '\]', '\000'
          \xff]                  # to '\037', '\x80' to '\xff'

        )                      # end of look-ahead

       |                      # OR

        \[                     # '['

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015\[           # to '\xff', '\n' (newline), '\015',
          \]]                    # '\[', '\]'

         |                      # OR

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

        )*                     # end of grouping

        \]                     # ']'

      )                      # end of grouping

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \.                     # '.'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            (?x:                   # group, but do not capture:

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

             |                      # OR

              \(                     # '('

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

              (?x:                   # group, but do not capture (0
                                     # or more times (matching the
                                     # most amount possible)):

                \\                     # '\'

                [^\x80                 # any character except: '\x80'
                -\xff]                 # to '\xff'

                [^\\\x                 # any character except: '\\',
                80-                    # '\x80' to '\xff', '\n'
                \xff\n                 # (newline), '\015', '(', ')'
                \015()                 # (0 or more times (matching
                ]*                     # the most amount possible))

              )*                     # end of grouping

              \)                     # ')'

            )                      # end of grouping

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

          [\040\t]*              # any character of: '\040', '\t'
                                 # (tab) (0 or more times (matching
                                 # the most amount possible))

        )*                     # end of grouping

        (?x:                   # group, but do not capture:

          [^(\040)<>@,           # any character except: '(', '\040',
          ;:".\\\[\]\0           # ')', '<', '>', '@', ',', ';', ':',
          00-\037\x80-           # '"', '.', '\\', '\[', '\]', '\000'
          \xff]+                 # to '\037', '\x80' to '\xff' (1 or
                                 # more times (matching the most
                                 # amount possible))

          (?!                    # look ahead to see if there is not:

            [^(\040)<>             # any character except: '(',
            @,;:".\\\[             # '\040', ')', '<', '>', '@', ',',
            \]\000-                # ';', ':', '"', '.', '\\', '\[',
            \037\x80-              # '\]', '\000' to '\037', '\x80'
            \xff]                  # to '\xff'

          )                      # end of look-ahead

         |                      # OR

          \[                     # '['

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            \[\]]                  # (newline), '\015', '\[', '\]'

           |                      # OR

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

          )*                     # end of grouping

          \]                     # ']'

        )                      # end of grouping

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            (?x:                   # group, but do not capture:

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

             |                      # OR

              \(                     # '('

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

              (?x:                   # group, but do not capture (0
                                     # or more times (matching the
                                     # most amount possible)):

                \\                     # '\'

                [^\x80                 # any character except: '\x80'
                -\xff]                 # to '\xff'

                [^\\\x                 # any character except: '\\',
                80-                    # '\x80' to '\xff', '\n'
                \xff\n                 # (newline), '\015', '(', ')'
                \015()                 # (0 or more times (matching
                ]*                     # the most amount possible))

              )*                     # end of grouping

              \)                     # ')'

            )                      # end of grouping

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

          [\040\t]*              # any character of: '\040', '\t'
                                 # (tab) (0 or more times (matching
                                 # the most amount possible))

        )*                     # end of grouping

      )*                     # end of grouping

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        ,                      # ','

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            (?x:                   # group, but do not capture:

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

             |                      # OR

              \(                     # '('

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

              (?x:                   # group, but do not capture (0
                                     # or more times (matching the
                                     # most amount possible)):

                \\                     # '\'

                [^\x80                 # any character except: '\x80'
                -\xff]                 # to '\xff'

                [^\\\x                 # any character except: '\\',
                80-                    # '\x80' to '\xff', '\n'
                \xff\n                 # (newline), '\015', '(', ')'
                \015()                 # (0 or more times (matching
                ]*                     # the most amount possible))

              )*                     # end of grouping

              \)                     # ')'

            )                      # end of grouping

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

          [\040\t]*              # any character of: '\040', '\t'
                                 # (tab) (0 or more times (matching
                                 # the most amount possible))

        )*                     # end of grouping

        @                      # '@'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            (?x:                   # group, but do not capture:

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

             |                      # OR

              \(                     # '('

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

              (?x:                   # group, but do not capture (0
                                     # or more times (matching the
                                     # most amount possible)):

                \\                     # '\'

                [^\x80                 # any character except: '\x80'
                -\xff]                 # to '\xff'

                [^\\\x                 # any character except: '\\',
                80-                    # '\x80' to '\xff', '\n'
                \xff\n                 # (newline), '\015', '(', ')'
                \015()                 # (0 or more times (matching
                ]*                     # the most amount possible))

              )*                     # end of grouping

              \)                     # ')'

            )                      # end of grouping

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

          [\040\t]*              # any character of: '\040', '\t'
                                 # (tab) (0 or more times (matching
                                 # the most amount possible))

        )*                     # end of grouping

        (?x:                   # group, but do not capture:

          [^(\040)<>@,           # any character except: '(', '\040',
          ;:".\\\[\]\0           # ')', '<', '>', '@', ',', ';', ':',
          00-\037\x80-           # '"', '.', '\\', '\[', '\]', '\000'
          \xff]+                 # to '\037', '\x80' to '\xff' (1 or
                                 # more times (matching the most
                                 # amount possible))

          (?!                    # look ahead to see if there is not:

            [^(\040)<>             # any character except: '(',
            @,;:".\\\[             # '\040', ')', '<', '>', '@', ',',
            \]\000-                # ';', ':', '"', '.', '\\', '\[',
            \037\x80-              # '\]', '\000' to '\037', '\x80'
            \xff]                  # to '\xff'

          )                      # end of look-ahead

         |                      # OR

          \[                     # '['

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            \[\]]                  # (newline), '\015', '\[', '\]'

           |                      # OR

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

          )*                     # end of grouping

          \]                     # ']'

        )                      # end of grouping

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            (?x:                   # group, but do not capture:

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

             |                      # OR

              \(                     # '('

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

              (?x:                   # group, but do not capture (0
                                     # or more times (matching the
                                     # most amount possible)):

                \\                     # '\'

                [^\x80                 # any character except: '\x80'
                -\xff]                 # to '\xff'

                [^\\\x                 # any character except: '\\',
                80-                    # '\x80' to '\xff', '\n'
                \xff\n                 # (newline), '\015', '(', ')'
                \015()                 # (0 or more times (matching
                ]*                     # the most amount possible))

              )*                     # end of grouping

              \)                     # ')'

            )                      # end of grouping

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

          [\040\t]*              # any character of: '\040', '\t'
                                 # (tab) (0 or more times (matching
                                 # the most amount possible))

        )*                     # end of grouping

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \.                     # '.'

          [\040\t]*              # any character of: '\040', '\t'
                                 # (tab) (0 or more times (matching
                                 # the most amount possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              (?x:                   # group, but do not capture:

                \\                     # '\'

                [^\x80                 # any character except: '\x80'
                -\xff]                 # to '\xff'

               |                      # OR

                \(                     # '('

                [^\\\x                 # any character except: '\\',
                80-                    # '\x80' to '\xff', '\n'
                \xff\n                 # (newline), '\015', '(', ')'
                \015()                 # (0 or more times (matching
                ]*                     # the most amount possible))

                (?x:                   # group, but do not capture (0
                                       # or more times (matching the
                                       # most amount possible)):

                  \\                     # '\'

                  [^\x                   # any character except:
                  80-                    # '\x80' to '\xff'
                  \xff                   #
                  ]                      #

                  [^\\                   # any character except:
                  \x80                   # '\\', '\x80' to '\xff',
                  -                      # '\n' (newline), '\015',
                  \xff                   # '(', ')' (0 or more times
                  \n\0                   # (matching the most amount
                  15()                   # possible))
                  ]*                     #

                )*                     # end of grouping

                \)                     # ')'

              )                      # end of grouping

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

            [\040\t]*              # any character of: '\040', '\t'
                                   # (tab) (0 or more times (matching
                                   # the most amount possible))

          )*                     # end of grouping

          (?x:                   # group, but do not capture:

            [^(\040)<>             # any character except: '(',
            @,;:".\\\[             # '\040', ')', '<', '>', '@', ',',
            \]\000-                # ';', ':', '"', '.', '\\', '\[',
            \037\x80-              # '\]', '\000' to '\037', '\x80'
            \xff]+                 # to '\xff' (1 or more times
                                   # (matching the most amount
                                   # possible))

            (?!                    # look ahead to see if there is
                                   # not:

              [^(\040)               # any character except: '(',
              <>@,;:".               # '\040', ')', '<', '>', '@',
              \\\[\]\0               # ',', ';', ':', '"', '.', '\\',
              00-                    # '\[', '\]', '\000' to '\037',
              \037\x80               # '\x80' to '\xff'
              -\xff]                 #

            )                      # end of look-ahead

           |                      # OR

            \[                     # '['

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '\[', '\]'
              15\[\]]                #

             |                      # OR

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

            )*                     # end of grouping

            \]                     # ']'

          )                      # end of grouping

          [\040\t]*              # any character of: '\040', '\t'
                                 # (tab) (0 or more times (matching
                                 # the most amount possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              (?x:                   # group, but do not capture:

                \\                     # '\'

                [^\x80                 # any character except: '\x80'
                -\xff]                 # to '\xff'

               |                      # OR

                \(                     # '('

                [^\\\x                 # any character except: '\\',
                80-                    # '\x80' to '\xff', '\n'
                \xff\n                 # (newline), '\015', '(', ')'
                \015()                 # (0 or more times (matching
                ]*                     # the most amount possible))

                (?x:                   # group, but do not capture (0
                                       # or more times (matching the
                                       # most amount possible)):

                  \\                     # '\'

                  [^\x                   # any character except:
                  80-                    # '\x80' to '\xff'
                  \xff                   #
                  ]                      #

                  [^\\                   # any character except:
                  \x80                   # '\\', '\x80' to '\xff',
                  -                      # '\n' (newline), '\015',
                  \xff                   # '(', ')' (0 or more times
                  \n\0                   # (matching the most amount
                  15()                   # possible))
                  ]*                     #

                )*                     # end of grouping

                \)                     # ')'

              )                      # end of grouping

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

            [\040\t]*              # any character of: '\040', '\t'
                                   # (tab) (0 or more times (matching
                                   # the most amount possible))

          )*                     # end of grouping

        )*                     # end of grouping

      )*                     # end of grouping

      :                      # ':'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

    )?                     # end of grouping

    (?x:                   # group, but do not capture:

      [^(\040)<>@,;:".       # any character except: '(', '\040',
      \\\[\]\000-            # ')', '<', '>', '@', ',', ';', ':',
      \037\x80-\xff]+        # '"', '.', '\\', '\[', '\]', '\000' to
                             # '\037', '\x80' to '\xff' (1 or more
                             # times (matching the most amount
                             # possible))

      (?!                    # look ahead to see if there is not:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-\xff]         # '"', '.', '\\', '\[', '\]', '\000'
                               # to '\037', '\x80' to '\xff'

      )                      # end of look-ahead

     |                      # OR

      "                      # '"'

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015"]*          # '\xff', '\n' (newline), '\015', '"' (0
                             # or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \\                     # '\'

        [^\x80-\xff]           # any character except: '\x80' to
                               # '\xff'

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015"]*          # to '\xff', '\n' (newline), '\015',
                               # '"' (0 or more times (matching the
                               # most amount possible))

      )*                     # end of grouping

      "                      # '"'

    )                      # end of grouping

    [\040\t]*              # any character of: '\040', '\t' (tab) (0
                           # or more times (matching the most amount
                           # possible))

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \(                     # '('

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015()]*         # '\xff', '\n' (newline), '\015', '(',
                             # ')' (0 or more times (matching the
                             # most amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        (?x:                   # group, but do not capture:

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

         |                      # OR

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

        )                      # end of grouping

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

      )*                     # end of grouping

      \)                     # ')'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

    )*                     # end of grouping

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \.                     # '.'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

      (?x:                   # group, but do not capture:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-              # '"', '.', '\\', '\[', '\]', '\000'
        \xff]+                 # to '\037', '\x80' to '\xff' (1 or
                               # more times (matching the most amount
                               # possible))

        (?!                    # look ahead to see if there is not:

          [^(\040)<>@,           # any character except: '(', '\040',
          ;:".\\\[\]\0           # ')', '<', '>', '@', ',', ';', ':',
          00-\037\x80-           # '"', '.', '\\', '\[', '\]', '\000'
          \xff]                  # to '\037', '\x80' to '\xff'

        )                      # end of look-ahead

       |                      # OR

        "                      # '"'

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015"]*          # to '\xff', '\n' (newline), '\015',
                               # '"' (0 or more times (matching the
                               # most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015"]           # to '\xff', '\n' (newline), '\015',
          *                      # '"' (0 or more times (matching the
                                 # most amount possible))

        )*                     # end of grouping

        "                      # '"'

      )                      # end of grouping

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

    )*                     # end of grouping

    @                      # '@'

    [\040\t]*              # any character of: '\040', '\t' (tab) (0
                           # or more times (matching the most amount
                           # possible))

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \(                     # '('

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015()]*         # '\xff', '\n' (newline), '\015', '(',
                             # ')' (0 or more times (matching the
                             # most amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        (?x:                   # group, but do not capture:

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

         |                      # OR

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

        )                      # end of grouping

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

      )*                     # end of grouping

      \)                     # ')'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

    )*                     # end of grouping

    (?x:                   # group, but do not capture:

      [^(\040)<>@,;:".       # any character except: '(', '\040',
      \\\[\]\000-            # ')', '<', '>', '@', ',', ';', ':',
      \037\x80-\xff]+        # '"', '.', '\\', '\[', '\]', '\000' to
                             # '\037', '\x80' to '\xff' (1 or more
                             # times (matching the most amount
                             # possible))

      (?!                    # look ahead to see if there is not:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-\xff]         # '"', '.', '\\', '\[', '\]', '\000'
                               # to '\037', '\x80' to '\xff'

      )                      # end of look-ahead

     |                      # OR

      \[                     # '['

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015\[\]         # to '\xff', '\n' (newline), '\015',
        ]                      # '\[', '\]'

       |                      # OR

        \\                     # '\'

        [^\x80-\xff]           # any character except: '\x80' to
                               # '\xff'

      )*                     # end of grouping

      \]                     # ']'

    )                      # end of grouping

    [\040\t]*              # any character of: '\040', '\t' (tab) (0
                           # or more times (matching the most amount
                           # possible))

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \(                     # '('

      [^\\\x80-              # any character except: '\\', '\x80' to
      \xff\n\015()]*         # '\xff', '\n' (newline), '\015', '(',
                             # ')' (0 or more times (matching the
                             # most amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        (?x:                   # group, but do not capture:

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

         |                      # OR

          \(                     # '('

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

          (?x:                   # group, but do not capture (0 or
                                 # more times (matching the most
                                 # amount possible)):

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

          )*                     # end of grouping

          \)                     # ')'

        )                      # end of grouping

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

      )*                     # end of grouping

      \)                     # ')'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

    )*                     # end of grouping

    (?x:                   # group, but do not capture (0 or more
                           # times (matching the most amount
                           # possible)):

      \.                     # '.'

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

      (?x:                   # group, but do not capture:

        [^(\040)<>@,;:         # any character except: '(', '\040',
        ".\\\[\]\000-          # ')', '<', '>', '@', ',', ';', ':',
        \037\x80-              # '"', '.', '\\', '\[', '\]', '\000'
        \xff]+                 # to '\037', '\x80' to '\xff' (1 or
                               # more times (matching the most amount
                               # possible))

        (?!                    # look ahead to see if there is not:

          [^(\040)<>@,           # any character except: '(', '\040',
          ;:".\\\[\]\0           # ')', '<', '>', '@', ',', ';', ':',
          00-\037\x80-           # '"', '.', '\\', '\[', '\]', '\000'
          \xff]                  # to '\037', '\x80' to '\xff'

        )                      # end of look-ahead

       |                      # OR

        \[                     # '['

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015\[           # to '\xff', '\n' (newline), '\015',
          \]]                    # '\[', '\]'

         |                      # OR

          \\                     # '\'

          [^\x80-\xff]           # any character except: '\x80' to
                                 # '\xff'

        )*                     # end of grouping

        \]                     # ']'

      )                      # end of grouping

      [\040\t]*              # any character of: '\040', '\t' (tab)
                             # (0 or more times (matching the most
                             # amount possible))

      (?x:                   # group, but do not capture (0 or more
                             # times (matching the most amount
                             # possible)):

        \(                     # '('

        [^\\\x80-              # any character except: '\\', '\x80'
        \xff\n\015()]*         # to '\xff', '\n' (newline), '\015',
                               # '(', ')' (0 or more times (matching
                               # the most amount possible))

        (?x:                   # group, but do not capture (0 or more
                               # times (matching the most amount
                               # possible)):

          (?x:                   # group, but do not capture:

            \\                     # '\'

            [^\x80-                # any character except: '\x80' to
            \xff]                  # '\xff'

           |                      # OR

            \(                     # '('

            [^\\\x80-              # any character except: '\\',
            \xff\n\015             # '\x80' to '\xff', '\n'
            ()]*                   # (newline), '\015', '(', ')' (0
                                   # or more times (matching the most
                                   # amount possible))

            (?x:                   # group, but do not capture (0 or
                                   # more times (matching the most
                                   # amount possible)):

              \\                     # '\'

              [^\x80-                # any character except: '\x80'
              \xff]                  # to '\xff'

              [^\\\x80               # any character except: '\\',
              -                      # '\x80' to '\xff', '\n'
              \xff\n\0               # (newline), '\015', '(', ')' (0
              15()]*                 # or more times (matching the
                                     # most amount possible))

            )*                     # end of grouping

            \)                     # ')'

          )                      # end of grouping

          [^\\\x80-              # any character except: '\\', '\x80'
          \xff\n\015()           # to '\xff', '\n' (newline), '\015',
          ]*                     # '(', ')' (0 or more times
                                 # (matching the most amount
                                 # possible))

        )*                     # end of grouping

        \)                     # ')'

        [\040\t]*              # any character of: '\040', '\t' (tab)
                               # (0 or more times (matching the most
                               # amount possible))

      )*                     # end of grouping

    )*                     # end of grouping

    >                      # '>'

  )                      # end of grouping

)                      # end of grouping
