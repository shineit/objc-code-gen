#
#created by jayson.xu
#


require 'nokogiri'
require './xib_2_objc.rb'

class UIKitFactory
  
  def self.UIKitObj(xml_obj,name)
    
      if xml_obj.name == 'label'
        return UILabel.new(xml_obj,name)
      elsif xml_obj.name == 'button'
        return UIButton.new(xml_obj,name)
      elsif xml_obj.name == 'imageView'
        return UIImageView.new(xml_obj,name)
      else
        return UIView.new(xml_obj,name)
      end
  end
  
end
  
class UIView
    
  protected
    attr_accessor :name, :xml_obj

  
  public
    attr_accessor :x, :y, :w, :h
    attr_accessor :background_color
    attr_accessor :alpha
    attr_accessor :hidden
    
    def initialize(xml_obj,name)
       @name = name
       @xml_obj = xml_obj
       rect = xml_obj.at_xpath("rect")
       @x = rect["x"].to_f
       @y = rect["y"].to_f
       @w = rect["width"].to_f
       @h = rect["height"].to_f
      
    end
 
    
    def objc_code()
      
      str = "\n   //#{self.name}"
      str = str+ "\n   self.#{self.name} =[[#{self.class} alloc]initWithFrame:CGRectMake(#{self.x},#{self.y},#{self.w},#{self.h})];"
      
      #返回字符串和sel数组
      code,sels = self.objc_code_subclass()
      
      str = str + code + "\n   [self addSubview:self.#{self.name}];"
        
      return str,sels
          
    end
  
  end
  
  class UIButton < UIView
    
    attr_accessor :button_type, :title_font, :title_color_normal, :title_color_highlight, :title_normal, :title_highlight
    attr_accessor :btn_type_4_UIKit
    
    def initialize(xml_obj,name)
      
        super(xml_obj,name)
        
        @normal_state_dict = Hash.new
        @highlight_state_dict = Hash.new
        @btn_type_4_UIKit = {"contactAdd" => "UIButtonTypeContactAdd", 
                          "roundedRect" => "UIButtonTypeRoundedRect"}
        
        @button_type = @btn_type_4_UIKit[xml_obj["buttonType"]];
        #font:
        font = xml_obj.at_xpath("fontDescription")
        
        if font != nil
          font_size = font["pointSize"]
        
          if font["type"] == "boldSystem"
            @title_font = "[UIFont boldSystemFontOfSize:#{font_size}]"
          else
            @title_font = "[UIFont systemFontOfSize:#{font_size}]"
          end
        end
    
        #state:
        state = xml_obj.at_xpath("state")
        if state["key"] == "normal"
          @title_normal = state["title"]
          color = state.at_xpath("color")
          
          if color["red"] != nil && color["green"] != nil && color["blue"] != nil
            @title_color_normal = "[UIColor colorWithRed:#{color["red"]} green:#{color["green"]} blue:#{color["blue"]} alpha:#{color["alpha"]}]"
          end
          
        elsif state["key"] == "highlight"
          
          @title_highlight = state["title"]
          color = state.at_xpath("color")
          
          if color["red"] != nil && color["green"] != nil && color["blue"] != nil
            @title_color_highlight = "[UIColor colorWithRed:#{color["red"]} green:#{color["green"]} blue:#{color["blue"]} alpha:#{color["alpha"]}]"
          end
          
        else
          ##todo
        end        
    end
    
    def objc_code()

      str = "\n   //#{self.name}"
      str = str + "\n   self.#{self.name} = [UIButton buttonWithType:#{self.button_type}];"
      str = str + "\n   self.#{self.name}.frame = CGRectMake(#{self.x},#{self.y},#{self.w},#{self.h});"
      str = str + "\n   [self addSubview:self.#{self.name}];"
      ##normal state
      
      if @title_normal != nil
        str = str + "\n   [self.#{self.name} setTitle:@\"#{self.title_normal}\" forState:UIControlStateNormal];"
      end
      
      if @title_color_normal != nil
        str = str + "\n   [self.#{self.name} setTitleColor:#{self.title_color_normal} forState:UIControlStateNormal];"
      end
      
      ##highlight state
      if @title_highlight != nil
      str = str + "\n   [self.#{self.name} setTitle:@\"#{self.title_highlight}\" forState:UIControlStateHighlighted];"
      end
      
      if @title_color_highlight != nil
      str = str + "\n   [self.#{self.name} setTitleColor:#{self.title_color_highlight} forState:UIControlStateHighlighted];"
      end
      
      ##font
      if self.title_font != nil
        str = str + "\n   self.#{self.name}.titleLabel.font = #{self.title_font};"
      end
      
      ##target-action
      str = str + "\n   [self.#{self.name} addTarget:self action:@selector(on#{self.name.capitalize}Clicked:) forControlEvents:UIControlEventTouchUpInside];"
      
      return str,["- (void)on#{self.name.capitalize}Clicked:(UIButton*)btn{ \n\n    //todo... \n }\n"]    
    end
  
  end
  

  
  class UILabel < UIView
    attr_accessor :font, :text, :text_color, :text_alignment, :text_linebreak_mode
    
    def initialize(xml_obj,name)
      
      super(xml_obj,name)
      
      #font:
      font = xml_obj.at_xpath("fontDescription")
        font_size = font["pointSize"]
        
        if font["type"] == "boldSystem"
          @font = "[UIFont boldSystemFontOfSize:#{font_size}]"
        else
          @font = "[UIFont systemFontOfSize:#{font_size}]"
        
        end
        
      #text color:
      color = xml_obj.at_xpath("color")
      @text_color = "[UIColor colorWithRed:#{color["red"]} green:#{color["green"]} blue:#{color["blue"]} alpha:#{color["alpha"]}]"
      
      #breakmode:
      breakmode = xml_obj["lineBreakMode"]
      if breakmode == "tailTruncation"
        @text_linebreak_mode = "NSLineBreakByTruncatingTail"
      end
      
      #text:
      @text = xml_obj["text"]
      
      #alignment
      @text_alignment = "NSTextAlignmentLeft"
      
      
    end
    
    def objc_code_subclass()
      
      str = ""
      str = str + "\n   self.#{self.name}.font = #{self.font};"
      str = str + "\n   self.#{self.name}.textColor = #{self.text_color};"
      str = str + "\n   self.#{self.name}.text = @\"#{self.text}\";"
      str = str + "\n   self.#{self.name}.textAlignment = #{self.text_alignment};"
      str = str + "\n   self.#{self.name}.lineBreakMode = #{self.text_linebreak_mode};"
      
      return str,Array.new
          
    end
    
  end
  
  class UIImageView < UIView
  
   def objc_code_subclass()
     return "",Array.new
   end
  
  end
