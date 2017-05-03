module.exports = function(grunt){

	require("matchdep").filterDev("grunt-*").forEach(grunt.loadNpmTasks);

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
		concat: {
			options: { separator: '\n\n' },
			js : {
				src: ['LICENSE.txt', 'WebCrypto.js'],
				dest: 'WebCrypto.js'
			}
		},
        uglify: {
		    build: {
		        files: {
		            'WebCrypto.js': ['source.js']
		        }
		    }
		},
		watch: {
		    js: {
		        files: ['source.js'],
		        tasks: ['buildall']
		    }
		}
    });

	grunt.registerTask('default', ['buildall','watch']);
	grunt.registerTask('buildall', ['uglify:build','concat:js']);

};