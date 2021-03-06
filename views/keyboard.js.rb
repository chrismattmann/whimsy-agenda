#
# Respond to keyboard events
#

class Keyboard
  @@control = false

  def self.control
    @@control
  end
  
  def self.initEventHandlers()

    # track control key
    def (document.body).onkeyup(event)
      if @@control != event.ctrlKey
        @@control = event.ctrlKey
        Main.refresh()
      end
    end

    # track control key + keyboard navigation (unless on the search screen)
    def (document.body).onkeydown(event)
      if @@control != event.ctrlKey
        @@control = event.ctrlKey
        Main.refresh()
      end

      return if ~'#search-text'[0] or ~'.modal-open'[0]
      return if event.metaKey or event.ctrlKey

      if event.keyCode == 37 # '<-'
        link = ~"a[rel=prev]"[0]
        if link
          Main.navigate link.getAttribute('href')
          window.scrollTo(0, 0)
          return false
        end
      elsif event.keyCode == 39 # '->'
        link = ~"a[rel=next]"[0]
        if link
          Main.navigate link.getAttribute('href')
          window.scrollTo(0, 0)
          return false
        end
      elsif event.keyCode == 13 # 'enter'
        link = ~".default"[0]
        Main.navigate link.getAttribute('href') if link
        return false
      elsif event.keyCode == 'C'.ord
        link = ~"#comments"[0]
        if link
          link.scrollIntoView()
        else
          Main.navigate 'comments'
        end
        return false
      elsif event.keyCode == 'I'.ord
        ~"#info".click
        return false
      elsif event.keyCode == 'N'.ord
        ~"#nav".click
        return false
      elsif event.keyCode == 'A'.ord
        Main.navigate '.'
        return false
      elsif event.keyCode == 'S'.ord
        link = ~"#shepherd"[0]
        Main.navigate link.getAttribute('href') if link
        return false
      elsif event.keyCode == 'Q'.ord
        Main.navigate "queue"
        return false
      elsif event.shiftKey and event.keyCode == 191 # "?"
        Main.navigate "help"
        return false
      elsif event.keyCode == 'R'.ord
        clock_counter += 1
        Main.refresh()
        post 'refresh', agenda: Agenda.file do |response|
          clock_counter -= 1
          Agenda.load response.agenda
          Main.refresh()
        end
        return false
      end
    end

  end
end
