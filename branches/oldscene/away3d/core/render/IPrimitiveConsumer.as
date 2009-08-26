package away3d.core.render
{
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    /** Interface for containers capable of drawing primitives */
    public interface IPrimitiveConsumer
    {
        function primitive(pri:DrawPrimitive):void;
    }
}