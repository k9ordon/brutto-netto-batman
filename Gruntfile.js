module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        concat: {
            options: { separator: ';\n' },
            app: {
                files: {
                    'dist/app.js': [ 'data/*.js', 'dist/app.js' ]
                },
            }
        },
        sass: {
            app: {
                files: {
                    "dist/app.css": "app.sass"
                }
            }
        },
        jade: {
            chromeapp: {
                files: {
                    "dist/index.html": ["app.jade"]
                }
            }
        },
        coffee: {
            app: {
                options: { sourceMap: true },
                files: {
                    'dist/app.js': [ 'app.coffee' ]
                }
            }
        },
        watch: {
            app: {
                files: '*',
                tasks: ['default']
            }
        },
        clean: {
            onBuild: ["dist/"],
        },
    });

    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-jade');
    grunt.loadNpmTasks('grunt-sass');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-clean');

    grunt.registerTask('default', [
        'clean:onBuild',  
        'sass',
        'jade', 
        'coffee', 
        'concat'
    ]);
};