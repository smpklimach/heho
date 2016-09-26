module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        # https://github.com/gruntjs/grunt-contrib-connect
        connect:
            server:
                options:
                    port: 8000
                    hostname: '*'
                    base: 'build/dev'
                    protocol: 'http'
                    livereload: yes

        # https://github.com/gruntjs/grunt-contrib-sass
        sass:
            dev:
                options:
                    style: "expanded"
                files: [
                    expand: true
                    cwd: "src/themes/ridingbytes/static/scss"
                    src: ["*.scss"]
                    dest: 'src/themes/ridingbytes/static/css'
                    ext: '.css'
                ]

        # https://github.com/andismith/grunt-responsive-images
        responsive_images:
            process:
                options:
                    engine: 'im'  # im=ImageMagick, gm=GraphicsMagick
                    separator: '_'
                    sizes: [
                        { rename: false, width: '100%', height: '100%' }   # Copy the source.
                        { name: 'large', width: 1600, aspectRatio: true }  # At most 1600px wide
                        { name: 'medium', width: 800, aspectRatio: true }  # At most 800px wide
                        # { name: 'small', width: 400, aspectRatio: true }   # At most 400px wide
                        # { name: 'tiny', width: 200, aspectRatio: true }    # At most 200px wide
                        # { name: 'thumb', height: 64, aspectRatio: true }   # At most 64px high
                    ]
                files: [
                    expand: true
                    cwd: 'images'
                    src: '**/**.{png,jpg,jpeg,gif}'
                    dest: 'src/themes/ridingbytes/static/img/'
                ]

        # https://github.com/gruntjs/grunt-contrib-watch
        watch:
            options:
                 atBegin: true
                 livereload: true

            # watch the whole source directory for changes
            hugo:
                files: ["src/*.toml", "src/**/*.html", "src/**/*.css",
                        "src/**/*.md", "src/**/*.png", "src/**/*.jpg"]
                tasks: ["hugo:dev"]
                options:
                    livereload: yes

            # watch all scss files for changes
            sass:
                files: ["src/**/*.scss"]
                tasks: ['sass:dev']
                options:
                    livereload: yes

            images:
                files: ['images/**/*']
                tasks: 'responsive_images'


    # dependencies
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-responsive-images'

    # custom tasks
    grunt.registerTask 'default', ["connect", "watch"]
    grunt.registerTask 'build', ["sass:dev", "responsive_images", "hugo:public"]

    # http://gohugo.io
    grunt.registerTask 'hugo', (target) ->
        done = @async()
        args = ['--source=src', "--destination=../build/#{target}"]
        if target == 'dev'
            args.push '--baseUrl=http://localhost:8000'
            args.push '--buildDrafts=true'
            args.push '--buildFuture=true'
        hugo = require('child_process').spawn 'hugo', args, stdio: 'inherit'
        (hugo.on e, -> done(true)) for e in ['exit', 'error']
