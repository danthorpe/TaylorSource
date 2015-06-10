namespace :xcode do

	def exportXcodeVersion
		command = "xcodebuild -version"
		sh command
	end
	
	def killSimulator
		command = "killall QUIT iOS\ Simulator"
		result = system(command)
	end
	
	def message(text)
		puts "--- #{text}"
	end

	def updateSubmodules
		message("Updating Submodules")
		command = "git submodule update --init"
		result = system(command)
	end

	def provideDefaultEnvironmentVariables
		ENV['OUTPUT_DIR'] = 'output' unless ENV.has_key?('OUTPUT_DIR')		
		ENV['ARTIFACT_DIR'] = 'artifacts' unless ENV.has_key?('ARTIFACT_DIR')
		ENV['SDK'] = 'iphonesimulator' unless ENV.has_key?('SDK')
		ENV['CONFIGURATION'] = 'Debug' unless ENV.has_key?('CONFIGURATION')
	end

	def projectDirectory(project)
		return "#{Dir.pwd}/#{project}"
	end

	def podsRoot(project)
		return "#{projectDirectory(project)}/Pods"
	end

	def workspaceArgument(project, workspace)
		return "-workspace \"#{project}/#{workspace}.xcworkspace\""
	end

	def configurationArgument
		return "-configuration #{ENV['CONFIGURATION']}"
	end

	def derivedDataPathArgument
		return "-derivedDataPath #{ENV['OUTPUT_DIR']}"
	end

	def buildProductsDirectory
		return "#{Dir.pwd}/#{ENV['OUTPUT_DIR']}/Build/Products/#{ENV['CONFIGURATION']}-iphoneos"	
	end

  def archivePath(scheme)
		return "#{Dir.pwd}/#{ENV['ARTIFACT_DIR']}/#{scheme}.xcarchive"    
  end

  def archivePathArgument(scheme)
    path = archivePath(scheme)
		return "-archivePath #{path}"
  end

	def packageApplicationArgument(scheme)
		return "#{buildProductsDirectory()}/#{scheme}.app"	
	end

	def packageOutputArgument
		return "#{Dir.pwd}/#{ENV['ARTIFACT_DIR']}"
	end

	def codeSigningArgument
		return "OTHER_CODE_SIGN_FLAGS=\"--keychain #{ENV['KEYCHAIN']}\""
	end

	def checkPods(project)
		manifest = "#{podsRoot(project)}/Manifest.lock"
		if File.file? manifest
			message("Updating Cocoapods in #{project}")
			sh "pod update"
		else
			message("Installing Cocoapods in #{project}")		
			sh "pod install"
		end
	end

	def prepareForBuild
		command = "mkdir -p #{ENV['OUTPUT_DIR']}"
		sh command
	end

	def prepareForArtifacts
		command = "mkdir -p #{ENV['ARTIFACT_DIR']}"
		sh command
	end

	def test(project, workspace, scheme)
#    command = "xctool #{workspaceArgument(project, workspace)} #{configurationArgument()} -sdk #{ENV['SDK']} -scheme #{scheme} -reporter pretty test && exit ${PIPESTATUS[0]}"
    command = "xcodebuild #{workspaceArgument(project, workspace)} #{configurationArgument()} -sdk #{ENV['SDK']} -scheme #{scheme} clean build test | xcpretty -c && exit ${PIPESTATUS[0]}"
		sh command
	end

	def build(project, workspace, scheme, app)
		message("Building #{scheme}")	
		prepareForBuild()
		command = "xcodebuild #{workspaceArgument(project, workspace)} #{configurationArgument()} -sdk iphoneos -scheme #{scheme} #{derivedDataPathArgument()} clean build | xcpretty -c && exit ${PIPESTATUS[0]}"
		sh command
	end

	def package(workspace, scheme, ipa)
		message("Packaging #{scheme}")	
		prepareForArtifacts()
		command = "xcrun -sdk iphoneos PackageApplication -v \"#{packageApplicationArgument(scheme)}\" -o \"#{packageOutputArgument()}/#{ipa}\""
		sh command
	end
  
  def archive(workspace, scheme)
    message("Archiving #{scheme}")
    command = "xcodebuild #{workspaceArgument()} #{configurationArgument()} -sdk iphoneos -scheme #{scheme} #{archivePathArgument(scheme)} clean archive | xcpretty -c && exit ${PIPESTATUS[0]}"
		sh command    
  end
  
  def distribute_hockey(workspace, scheme)
		message("Distributing #{scheme} To HockeyApp")
    command = "/usr/local/bin/puck -submit=auto -download=true -notify=false -upload=all -mandatory=false -build_server_url=#{ENV['BUILDBOX_BUILD_URL']} -commit_sha=#{ENV['BUILDBOX_COMMIT']} -repository_url=#{ENV['BUILDBOX_REPO']} -app_id=#{ENV['HOCKEYAPP_ID']} -api_token=#{ENV['HOCKEYAPP_TOKEN']} #{archivePathArgument(scheme)}"
		sh command
  end
	
	desc 'Configure Environment'
	task :configure_env do
		exportXcodeVersion()
		provideDefaultEnvironmentVariables()		
	end

	desc 'Update Submodules'
	task :update_submodules do
		updateSubmodules()
	end

  namespace :pods do

  	desc 'Update Cocoapods for YOMDomain'
  	task :Example2 => [:configure_env] do 
      projectDir = projectDirectory('frameworks/YOMDomain/YOMDomainTests')
  		Dir.chdir(projectDir) do
  			checkPods('frameworks/YOMDomain/YOMDomainTests')
  		end
  	end

  	desc 'Update Cocoapods for YOMAuth'
  	task :Example1 => [:configure_env] do 
      projectDir = projectDirectory('frameworks/YOMAuth/YOMAuthTests')
  		Dir.chdir(projectDir) do
  			checkPods('frameworks/YOMAuth/YOMAuthTests')
  		end
  	end

  	desc 'Update Cocoapods for YOM'
  	task :Framework => [:configure_env] do
      projectDir = projectDirectory('framework')
  		Dir.chdir(projectDir) do			
  			checkPods('framework')
  		end
  	end    
  end

	namespace :test do

		desc 'Runs all the Unit Tests'
		task :all => [:Framework, :Example1] do
		end

    task :Example2 => ['pods:Example2'] do
			message("Testing TaylorSource Example 2")
#			test('frameworks/YOMDomain/YOMDomainTests', 'YOMDomainTests', 'Tests')
    end

    task :Example1 => ['pods:Example1'] do
			message("Testing TaylorSource Example 1")
			test('examples/US\ Cities', 'US\ Cities', 'US\ Cities')
    end

		desc 'Runs Unit Tests for You Owe Me'
		task :Framework => ['pods:Framework'] do
			message("Testing TaylorSource")
			test('framework', 'TaylorSource', 'TaylorSource')
		end

	end		
end
