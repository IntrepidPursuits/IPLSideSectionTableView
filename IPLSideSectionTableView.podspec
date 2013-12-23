Pod::Spec.new do |s|
  s.name         = "IPLSideSectionTableView"
  s.version      = "0.1.0"
  s.summary      = "A UITableView subclass that puts the section headers on the left edge of the table view."
  s.description  = <<-DESC
                    This class lets you create a UITableView where the section header views are not displayed inline with the other cells, but along the left side of the table view instead. They still start at the same y coordinate they normally would, and they still scroll
                   DESC
  s.homepage     = "https://github.com/IntrepidPursuits/IPLSideSectionTableView"
  s.license      = 'New BSD'
  s.author       = { "Intrepid Pursuits" => "hello@intrepid.io" }
  s.source       = { :git => "https://github.com/IntrepidPursuits/IPLSideSectionTableView.git", :tag => "0.1.0" }
  s.requires_arc = true
  s.source_files = 'Classes/**/*.{h,m}'
  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
end
